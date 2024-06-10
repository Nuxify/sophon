import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sophon/application/service/cubit/web3_cubit.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/gen/assets.gen.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<Web3Cubit>().instantiate();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 25,
            right: 25,
            bottom: 30,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Assets.images.space.image(width: width * 0.8),
                    const Text(
                      'Sophon',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Interact with the Smart Contract by connecting your wallet',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
              ),
              FadeIn(
                duration: const Duration(seconds: 2),
                child: BlocBuilder<Web3Cubit, Web3State>(
                  buildWhen: (Web3State previous, Web3State current) =>
                      current is Web3MInitialized,
                  builder: (BuildContext context, Web3State state) {
                    if (state is Web3MInitialized) {
                      return W3MConnectWalletButton(
                        context: context,
                        service: state.service,
                        custom: SizedBox(
                          width: width,
                          child: FilledButton(
                            onPressed: () => state.service.openModal(context),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(kPink),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Connect Wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Shimmer.fromColors(
                      baseColor: shimmerBase,
                      highlightColor: shimmerGlow,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: Colors.white,
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 45,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
