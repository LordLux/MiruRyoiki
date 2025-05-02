import 'package:fluent_ui/fluent_ui.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}
class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Accounts'),
    );
  }
}