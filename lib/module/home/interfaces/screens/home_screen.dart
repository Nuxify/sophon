import 'package:flutter/material.dart';
import 'package:sophon/configs/themes.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.session, required this.connector})
      : super(key: key);

  final dynamic session;
  final WalletConnect connector;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SessionStatus sessionStatus;
  String getNetworkName(chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 3:
        return 'Ropsten Testnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goerli Testnet';
      case 42:
        return 'Kovan Testnet';
      case 137:
        return 'Polygon Mainnet';
      default:
        return 'Unknown Chain';
    }
  }

  String truncateString(String text, int front, int end) {
    int size = front + end;
    if (text.length > size) {
      String finalString =
          "${text.substring(0, front)}...${text.substring(text.length - end)}";
      return finalString;
    }

    return text;
  }

  void closeConnection() {
    setState(() {
      widget.connector.killSession();
      widget.connector.close();
    });
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    sessionStatus = widget.session;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: violetGradient,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                vertical: height * 0.06,
                horizontal: width * 0.07,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFA166FE),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      offset: Offset(1, 5),
                      color: Colors.black38,
                      blurRadius: 10,
                    ),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Address: ',
                    style: theme.textTheme.headline6
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      Container(
                        width: width * 0.6,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          '${widget.session.accounts[0]}',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headline6?.copyWith(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.copy,
                          size: 18,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Chain: ',
                        style: theme.textTheme.headline6
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        getNetworkName(widget.session.chainId),
                        style: theme.textTheme.headline6?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                    padding: EdgeInsets.only(bottom: height * 0.05),
                    child: widget.connector.connected
                        ? ElevatedButton.icon(
                            onPressed: closeConnection,
                            icon: const Icon(Icons.close),
                            label: const Text('Close Connection'),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                              elevation: MaterialStateProperty.all(0),
                            ),
                          )
                        : const CircularProgressIndicator(color: kLightViolet)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
