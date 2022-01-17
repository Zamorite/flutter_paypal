import 'package:flutter/material.dart';
import 'package:flutter_paypal/src/errors/network_error.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../PaypalServices.dart';

class ActivateSubscription extends StatefulWidget {
  final Function onSuccess, onCancel, onError;
  final PaypalServices services;
  final String url,
      // executeUrl,
      accessToken;
  const ActivateSubscription({
    Key? key,
    required this.onSuccess,
    required this.onError,
    required this.onCancel,
    required this.services,
    required this.url,
    // required this.executeUrl,
    required this.accessToken,
  }) : super(key: key);

  @override
  _ActivateSubscriptionState createState() => _ActivateSubscriptionState();
}

class _ActivateSubscriptionState extends State<ActivateSubscription> {
  bool loading = true;
  bool loadingError = false;

  complete() async {
    final uri = Uri.parse(widget.url);
    final token = uri.queryParameters['ba_token'];

    if (token != null) {
      Map params = {
        "ba_token": token,
      };
      setState(() {
        loading = true;
        loadingError = false;
      });

      Map resp = await widget.services
          .approveSubscription(widget.url, widget.accessToken);

      if (resp['error'] == false) {
        params['status'] = 'success';
        params['data'] = resp['data'];
        await widget.onSuccess(params);
        setState(() {
          loading = false;
          loadingError = false;
        });
        Navigator.pop(context);
      } else {
        if (resp['exception'] != null && resp['exception'] == true) {
          widget.onError({"message": resp['message']});
          setState(() {
            loading = false;
            loadingError = true;
          });
        } else {
          await widget.onError(resp['data']);
          Navigator.of(context).pop();
        }
      }
      //return NavigationDecision.prevent;
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: loading
            ? Column(
                children: const [
                  Expanded(
                    child: Center(
                      child: SpinKitFadingCube(
                        color: Color(0xFFEB920D),
                        size: 30.0,
                      ),
                    ),
                  ),
                ],
              )
            : loadingError
                ? Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: NetworkError(
                              loadData: complete,
                              message: "Something went wrong,"),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Text("Payment Completed"),
                  ),
      ),
    );
  }
}
