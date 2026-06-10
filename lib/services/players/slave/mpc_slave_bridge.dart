// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../../../utils/logging.dart';

/// One `WM_COPYDATA` notification pushed by an MPC-HC slave instance
class MpcIncomingMessage {
  /// The MPC-HC window that sent the message (its main `HWND`)
  final int senderHwnd;

  /// The command code (`COPYDATASTRUCT.dwData`)
  final int command;

  /// The UTF-16 payload, or `''` when the command carries none
  final String payload;

  const MpcIncomingMessage(this.senderHwnd, this.command, this.payload);

  @override
  String toString() => 'MpcIncomingMessage(sender: $senderHwnd, cmd: 0x${command.toRadixString(16)}, "$payload")';
}

// Win32 definitions
const int _HWNDMESSAGE = -3; // HWND_MESSAGE: parent for a message-only window
const int _WMCOPYDATA = 0x004A; // WM_COPYDATA

final class COPYDATASTRUCT extends Struct {
  @IntPtr()
  external int dwData; // ULONG_PTR: carries the MpcCommand code

  @Uint32()
  external int cbData; // DWORD: payload byte length incl. terminator

  external Pointer<Void> lpData; // PVOID: UTF-16 payload
}

// Message tags exchanged over the SendPort
const String _tagReady = 'ready';
const String _tagCopyData = 'copydata';
const String _tagStopped = 'stopped';
const String _tagError = 'error';

const String _windowClassName = 'MiruRyoikiMpcSlaveHost';

/// The worker isolate's link back to the main isolate
///
/// Isolate-local: only the worker ever sets/reads it, and the static [_wndProc] reaches it through this top-level field
SendPort? _workerSink;

/// Window procedure for the message-only host window
///
/// Runs synchronously on the worker isolate's thread (invoked by `GetMessage`/`DispatchMessage`)
int _wndProc(int hwnd, int msg, int wParam, int lParam) {
  if (msg == _WMCOPYDATA) {
    try {
      final cds = Pointer<COPYDATASTRUCT>.fromAddress(lParam);
      final command = cds.ref.dwData;
      final byteCount = cds.ref.cbData;
      final dataPtr = cds.ref.lpData;

      // The payload is a null-terminated UTF-16 string;
      // copy it out while the cross-process pointer is still valid
      String payload = '';
      if (byteCount > 0 && dataPtr.address != 0) payload = dataPtr.cast<Utf16>().toDartString();

      // wParam is the sender's HWND per the WM_COPYDATA contract
      _workerSink?.send([_tagCopyData, wParam, command, payload]);
    } catch (_) {}
    return TRUE;
  }

  if (msg == WM_DESTROY) {
    PostQuitMessage(0);
    return 0;
  }

  return DefWindowProc(hwnd, msg, wParam, lParam);
}

/// Entry point for the worker isolate
///
/// - Registers a window class
/// - Creates a message-only window
/// - Reports its handle
/// - Then pumps messages until told to stop (via a `WM_CLOSE` posted by [MpcSlaveBridge.stop])
void _bridgeIsolateEntry(SendPort mainSendPort) {
  _workerSink = mainSendPort;

  final classNamePtr = _windowClassName.toNativeUtf16();
  final wndClass = calloc<WNDCLASS>();
  final msg = calloc<MSG>();

  try {
    // Best-effort cleanup of a class left registered by a previous run in the same process so our fresh WndProc is used
    UnregisterClass(classNamePtr, NULL);

    wndClass.ref.lpfnWndProc = Pointer.fromFunction<WNDPROC>(_wndProc, 0);
    wndClass.ref.hInstance = GetModuleHandle(nullptr);
    wndClass.ref.lpszClassName = classNamePtr;
    RegisterClass(wndClass);

    final hwnd = CreateWindowEx(
      0, //                         dwExStyle
      classNamePtr, //              lpClassName
      classNamePtr, //              lpWindowName
      0, //                         dwStyle
      0, 0, 0, 0, //                X, Y, nWidth, nHeight
      _HWNDMESSAGE, //              hWndParent -> message-only window
      NULL, //                      hMenu
      GetModuleHandle(nullptr), //  hInstance
      nullptr, //                   lpParam
    );

    if (hwnd == 0) {
      mainSendPort.send([_tagError, 'CreateWindowEx failed (error ${GetLastError()})']);
      return;
    }

    mainSendPort.send([_tagReady, hwnd]);

    // Pump messages;
    // WM_COPYDATA arrives via SendMessage and is delivered to _wndProc by GetMessage; GetMessage returns 0 on WM_QUIT
    int result;
    while ((result = GetMessage(msg, NULL, 0, 0)) != 0) {
      if (result == -1) break; // GetMessage error
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
  } finally {
    UnregisterClass(classNamePtr, NULL);
    calloc.free(wndClass);
    calloc.free(msg);
    calloc.free(classNamePtr);
    mainSendPort.send([_tagStopped]);
  }
}

/// Owns the native plumbing for MPC-HC slave mode: a hidden message-only window (on a dedicated isolate) that receives MPC-HC's `WM_COPYDATA` push notifications, plus the send paths used to control instances
///
/// Sending is a synchronous FFI `SendMessage` for `WM_COPYDATA` and a `PostMessage` for the `WM_COMMAND` fallback
class MpcSlaveBridge {
  MpcSlaveBridge._();
  static final MpcSlaveBridge instance = MpcSlaveBridge._();

  Isolate? _isolate;
  ReceivePort? _receivePort;
  int _hostHwnd = 0;
  Completer<int?>? _starting;

  final StreamController<MpcIncomingMessage> _incoming = StreamController<MpcIncomingMessage>.broadcast();

  /// Notifications pushed by every connected MPC-HC instance
  Stream<MpcIncomingMessage> get incoming => _incoming.stream;

  /// The host window handle MPC-HC must be launched against (`/slave <hwnd>`)
  /// Zero until [start] has succeeded
  int get hostHwnd => _hostHwnd;

  bool get isRunning => _hostHwnd != 0;

  /// Idempotent;
  /// Starts the message-only window and returns its handle (the `/slave` target), or `null` if it could not be created.
  Future<int?> start() async {
    if (_hostHwnd != 0) return _hostHwnd;
    if (_starting != null) return _starting!.future;

    final completer = Completer<int?>();
    _starting = completer;

    final port = ReceivePort();
    _receivePort = port;
    port.listen(_onWorkerMessage);

    try {
      _isolate = await Isolate.spawn(_bridgeIsolateEntry, port.sendPort, debugName: 'mpc-slave-bridge');
    } catch (e, st) {
      logErr('Failed to spawn MPC-HC slave bridge isolate', e, st);
      _cleanup();
      if (!completer.isCompleted) completer.complete(null);
      _starting = null;
    }

    return completer.future;
  }

  void _onWorkerMessage(dynamic data) {
    if (data is! List || data.isEmpty) return;

    switch (data[0]) {
      case _tagReady:
        _hostHwnd = data[1] as int;
        logTrace('MPC-HC slave bridge ready (host hwnd: $_hostHwnd)');
        _starting?.complete(_hostHwnd);
        _starting = null;
        break;

      case _tagCopyData:
        _incoming.add(MpcIncomingMessage(data[1] as int, data[2] as int, data[3] as String));
        break;

      case _tagError:
        logErr('MPC-HC slave bridge error: ${data[1]}');
        _starting?.complete(null);
        _starting = null;
        _cleanup();
        break;

      case _tagStopped:
        _cleanup();
        break;
    }
  }

  /// Sends a `WM_COPYDATA` command to a specific MPC-HC instance
  /// 
  /// The optional [payload] is encoded as a null-terminated UTF-16 string
  /// 
  /// No-op if the bridge isn't running or the target window is gone
  void send(int targetHwnd, int command, [String payload = '']) {
    if (_hostHwnd == 0 || targetHwnd == 0) return;
    if (IsWindow(targetHwnd) == 0) return;

    final dataPtr = payload.toNativeUtf16();
    final cds = calloc<COPYDATASTRUCT>();
    try {
      cds.ref.dwData = command;
      cds.ref.cbData = (payload.length + 1) * 2; // bytes incl. UTF-16 terminator
      cds.ref.lpData = dataPtr.cast();
      // The receiver copies the data before SendMessage returns synchronously -> safe to free afterward
      SendMessage(targetHwnd, _WMCOPYDATA, _hostHwnd, cds.address);
    } catch (e, st) {
      logErr('MPC-HC slave send failed (cmd 0x${command.toRadixString(16)})', e, st);
    } finally {
      calloc.free(cds);
      calloc.free(dataPtr);
    }
  }

  /// Whether [hwnd] still refers to a live window
  bool isInstanceAlive(int hwnd) => hwnd != 0 && IsWindow(hwnd) != 0;

  /// Sends a `WM_COMMAND` (0x111) with an MPC-HC command id (see `MpcWmCommand`) straight to the player window
  /// 
  /// Used for actions the slave API lacks (mute) and as a volume/next/previous fallback
  void sendWmCommand(int targetHwnd, int commandId) {
    if (targetHwnd == 0 || IsWindow(targetHwnd) == 0) return;
    PostMessage(targetHwnd, WM_COMMAND, commandId, 0);
  }

  /// Tears down the message-only window and worker isolate. Idempotent
  Future<void> stop() async {
    final hwnd = _hostHwnd;
    if (hwnd != 0) {
      // Ask the worker thread to destroy its own window (DestroyWindow must run
      // on the creating thread); WM_CLOSE -> DefWindowProc -> WM_DESTROY ->
      // PostQuitMessage unwinds the message loop cleanly
      PostMessage(hwnd, WM_CLOSE, 0, 0);
    }
    // Give the worker a brief moment to unwind before force-killing
    await Future.delayed(const Duration(milliseconds: 50));
    _cleanup();
  }

  void _cleanup() {
    _hostHwnd = 0;
    _receivePort?.close();
    _receivePort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}
