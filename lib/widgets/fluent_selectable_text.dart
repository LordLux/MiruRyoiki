import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart' as ui;
import 'package:flutter/material.dart' as mat;

import '../manager.dart';

class FluentSelectableText extends StatelessWidget {
  final TextSpan text;
  final bool selectable;
  final Color? _selectionColor;
  final FocusNode? focusNode;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final double? textScaleFactor;
  final TextScaler? textScaler;
  final bool showCursor;
  final bool autofocus;
  final ToolbarOptions? toolbarOptions;
  final int? minLines;
  final int? maxLines;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final ui.DragStartBehavior dragStartBehavior;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final void Function()? onTap;
  final ScrollPhysics? scrollPhysics;
  final ScrollBehavior? scrollBehavior;
  final String? semanticsLabel;
  final TextHeightBehavior? textHeightBehavior;
  final TextWidthBasis? textWidthBasis;
  final void Function(TextSelection, SelectionChangedCause?)? onSelectionChanged;
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final TextOverflow? overflow;

  const FluentSelectableText._(
    this.text, {
    super.key,
    this.selectable = true,
    Color? selectionColor,
    this.focusNode,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.textScaleFactor,
    this.textScaler,
    this.showCursor = false,
    this.autofocus = false,
    this.toolbarOptions,
    this.minLines,
    this.maxLines,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.dragStartBehavior = ui.DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.onTap,
    this.scrollPhysics,
    this.scrollBehavior,
    this.semanticsLabel,
    this.textHeightBehavior,
    this.textWidthBasis,
    this.onSelectionChanged,
    this.contextMenuBuilder,
    this.magnifierConfiguration,
    this.overflow,
  }) : _selectionColor = selectionColor;

  factory FluentSelectableText.rich(
    TextSpan text, {
    Key? key,
    TextStyle? style,
    bool selectable = true,
    Color? selectionColor,
    FocusNode? focusNode,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    double? textScaleFactor,
    TextScaler? textScaler,
    bool showCursor = false,
    bool autofocus = false,
    ToolbarOptions? toolbarOptions,
    int? minLines,
    int? maxLines,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    ui.DragStartBehavior dragStartBehavior = ui.DragStartBehavior.start,
    bool enableInteractiveSelection = true,
    TextSelectionControls? selectionControls,
    void Function()? onTap,
    ScrollPhysics? scrollPhysics,
    ScrollBehavior? scrollBehavior,
    String? semanticsLabel,
    TextHeightBehavior? textHeightBehavior,
    TextWidthBasis? textWidthBasis,
    void Function(TextSelection, SelectionChangedCause?)? onSelectionChanged,
    Widget Function(BuildContext, EditableTextState)? contextMenuBuilder,
    TextMagnifierConfiguration? magnifierConfiguration,
    TextOverflow? overflow,
  }) {
    return FluentSelectableText._(
      text,
      key: key,
      style: Manager.bodyStyle.merge(style),
      selectable: selectable,
      selectionColor: selectionColor,
      focusNode: focusNode,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      textScaler: textScaler,
      showCursor: showCursor,
      autofocus: autofocus,
      toolbarOptions: toolbarOptions,
      minLines: minLines,
      maxLines: maxLines,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      selectionHeightStyle: selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle,
      dragStartBehavior: dragStartBehavior,
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      onTap: onTap,
      scrollPhysics: scrollPhysics,
      scrollBehavior: scrollBehavior,
      semanticsLabel: semanticsLabel,
      textHeightBehavior: textHeightBehavior,
      textWidthBasis: textWidthBasis,
      onSelectionChanged: onSelectionChanged,
      contextMenuBuilder: contextMenuBuilder,
      magnifierConfiguration: magnifierConfiguration,
      overflow: overflow,
    );
  }

  factory FluentSelectableText.spans(
    List<InlineSpan> spans, {
    Key? key,
    TextStyle? style,
    bool selectable = true,
    Color? selectionColor,
    FocusNode? focusNode,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    double? textScaleFactor,
    TextScaler? textScaler,
    bool showCursor = false,
    bool autofocus = false,
    ToolbarOptions? toolbarOptions,
    int? minLines,
    int? maxLines,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    ui.DragStartBehavior dragStartBehavior = ui.DragStartBehavior.start,
    bool enableInteractiveSelection = true,
    TextSelectionControls? selectionControls,
    void Function()? onTap,
    ScrollPhysics? scrollPhysics,
    ScrollBehavior? scrollBehavior,
    String? semanticsLabel,
    TextHeightBehavior? textHeightBehavior,
    TextWidthBasis? textWidthBasis,
    void Function(TextSelection, SelectionChangedCause?)? onSelectionChanged,
    Widget Function(BuildContext, EditableTextState)? contextMenuBuilder,
    TextMagnifierConfiguration? magnifierConfiguration,
    TextOverflow? overflow,
  }) {
    return FluentSelectableText._(
      TextSpan(children: spans, style: Manager.bodyStyle.merge(style)),
      key: key,
      style: style,
      selectable: selectable,
      selectionColor: selectionColor,
      focusNode: focusNode,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      textScaler: textScaler,
      showCursor: showCursor,
      autofocus: autofocus,
      toolbarOptions: toolbarOptions,
      minLines: minLines,
      maxLines: maxLines,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      selectionHeightStyle: selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle,
      dragStartBehavior: dragStartBehavior,
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      onTap: onTap,
      scrollPhysics: scrollPhysics,
      scrollBehavior: scrollBehavior,
      semanticsLabel: semanticsLabel,
      textHeightBehavior: textHeightBehavior,
      textWidthBasis: textWidthBasis,
      onSelectionChanged: onSelectionChanged,
      contextMenuBuilder: contextMenuBuilder,
      magnifierConfiguration: magnifierConfiguration,
      overflow: overflow,
    );
  }

  factory FluentSelectableText(
    String text, {
    Key? key,
    TextStyle? style,
    bool selectable = true,
    Color? selectionColor,
    FocusNode? focusNode,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    double? textScaleFactor,
    TextScaler? textScaler,
    bool showCursor = false,
    bool autofocus = false,
    ToolbarOptions? toolbarOptions,
    int? minLines,
    int? maxLines,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    ui.DragStartBehavior dragStartBehavior = ui.DragStartBehavior.start,
    bool enableInteractiveSelection = true,
    TextSelectionControls? selectionControls,
    void Function()? onTap,
    ScrollPhysics? scrollPhysics,
    ScrollBehavior? scrollBehavior,
    String? semanticsLabel,
    TextHeightBehavior? textHeightBehavior,
    TextWidthBasis? textWidthBasis,
    void Function(TextSelection, SelectionChangedCause?)? onSelectionChanged,
    Widget Function(BuildContext, EditableTextState)? contextMenuBuilder,
    TextMagnifierConfiguration? magnifierConfiguration,
    TextOverflow? overflow,
  }) {
    return FluentSelectableText._(
      TextSpan(text: text, style: Manager.bodyStyle.merge(style)),
      key: key,
      style: style,
      selectable: selectable,
      selectionColor: selectionColor,
      focusNode: focusNode,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      textScaler: textScaler,
      showCursor: showCursor,
      autofocus: autofocus,
      toolbarOptions: toolbarOptions,
      minLines: minLines,
      maxLines: maxLines,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      selectionHeightStyle: selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle,
      dragStartBehavior: dragStartBehavior,
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      onTap: onTap,
      scrollPhysics: scrollPhysics,
      scrollBehavior: scrollBehavior,
      semanticsLabel: semanticsLabel,
      textHeightBehavior: textHeightBehavior,
      textWidthBasis: textWidthBasis,
      onSelectionChanged: onSelectionChanged,
      contextMenuBuilder: contextMenuBuilder,
      magnifierConfiguration: magnifierConfiguration,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final actSelectionColor = _selectionColor ?? Manager.currentDominantColor?.withOpacity(0.5) ?? Manager.accentColor.withOpacity(0.5);

    if (!selectable) {
      return RichText(
        text: text,
        overflow: overflow ?? TextOverflow.clip,
        maxLines: maxLines,
        textAlign: textAlign ?? TextAlign.start,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor ?? 1.0,
      );
    }

    return mat.Theme(
      data: mat.Theme.of(context).copyWith(
        textSelectionTheme: mat.TextSelectionThemeData(
          selectionColor: actSelectionColor,
          selectionHandleColor: actSelectionColor,
        ),
      ),
      child: mat.SelectableText.rich(
        text,
        focusNode: focusNode,
        style: style?.copyWith(overflow: overflow) ?? (overflow != null ? TextStyle(overflow: overflow) : null),
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor,
        textScaler: textScaler,
        showCursor: showCursor,
        autofocus: autofocus,
        toolbarOptions: toolbarOptions,
        minLines: minLines,
        maxLines: maxLines,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor ?? actSelectionColor,
        selectionHeightStyle: selectionHeightStyle,
        selectionWidthStyle: selectionWidthStyle,
        dragStartBehavior: dragStartBehavior,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: selectionControls ?? fluentTextSelectionControls,
        onTap: onTap,
        scrollPhysics: scrollPhysics,
        scrollBehavior: scrollBehavior,
        semanticsLabel: semanticsLabel,
        textHeightBehavior: textHeightBehavior,
        textWidthBasis: textWidthBasis,
        onSelectionChanged: onSelectionChanged,
        contextMenuBuilder: contextMenuBuilder,
        magnifierConfiguration: magnifierConfiguration,
      ),
    );
  }
}
