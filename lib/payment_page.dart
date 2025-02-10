import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController customAmountController = TextEditingController();

  String result = '';
  String environmentValue = 'SANDBOX';
  String appId = '';
  String merchantId = 'PGTESTPAYUAT115';
  bool enableLogging = true;
  String saltKey = 'f94f0bb9-bcfb-4077-adc0-3f8408a17bf7';
  String saltIndex = '1';
  String body = '';
  String callback = '';
  String checksum = '';
  String packageName = '';
  String apiEndPoint = "/pg/v1/pay";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    initPayment();
    body = getChecksum(11).toString();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initPayment() {
    PhonePePaymentSdk.init(environmentValue, appId, merchantId, enableLogging)
        .then((val) {
      setState(() {
        //result = 'PhonePe SDK Initialized - $val';
      });
    }).catchError((error) {
      handleError(error);
    });
  }

  void startTransaction(int amount) {
    body = getChecksum(amount).toString();
    PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName)
        .then((response) {
      setState(() {
        if (response != null) {
          String status = response['status'].toString();
          String error = response['error'].toString();
          if (status == 'SUCCESS') {
            result = "Flow Completed - Status: Success!";
          } else {
            //result = "Flow Completed - Status: $status and Error: $error";
          }
        } else {
          //result = "Flow Incomplete";
        }
      });
    }).catchError((error) {
      handleError(error);
    });
  }

  void handleError(error) {
    setState(() {
      result = error.toString();
    });
  }

  String getChecksum(int amount) {
    final reqData = {
      "merchantId": merchantId,
      "merchantTransactionId": "MT7850590068188104",
      "merchantUserId": "MUID123",
      "amount": amount * 100,
      "callbackUrl": callback,
      "mobileNumber": "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };
    String base64body = base64.encode(utf8.encode(json.encode(reqData)));
    checksum =
        '${sha256.convert(utf8.encode(base64body + apiEndPoint + saltKey)).toString()}###$saltIndex';
    return base64body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Farmer'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          // Animated Background using AnimatedContainer
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              color: Colors.green[100],
              curve: Curves.easeIn,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Animated Farmer Icon using FadeTransition
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Icon(Icons.person, size: 200, color: Colors.green),
                  ),
                  // Input Fields with enhanced styling
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              prefixIcon:
                                  const Icon(Icons.person, color: Colors.green),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: locationController,
                            decoration: InputDecoration(
                              labelText: 'Farmer Name/Location',
                              prefixIcon: const Icon(Icons.location_on,
                                  color: Colors.green),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Payment Amount Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Replace Lottie animation with ScaleTransition
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: const Icon(Icons.payment,
                                size: 100, color: Colors.green),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: customAmountController,
                            decoration: InputDecoration(
                              labelText: 'Enter Amount (₹)',
                              prefixIcon: const Icon(Icons.currency_rupee,
                                  color: Colors.green),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          int customAmount =
                              int.tryParse(customAmountController.text) ?? 0;
                          if (customAmount > 0) {
                            startTransaction(customAmount);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Please enter a valid amount")),
                            );
                          }
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Pay Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          String name = nameController.text;
                          String location = locationController.text;
                          if (name.isNotEmpty && location.isNotEmpty) {
                            bool success = await _generatePaymentReceipt(name, location);
                            if (success) {
                              _showReceiptDialog(name, location);
                            }
                          }
                        },
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Get Receipt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Status Display
                  if (result.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        result,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _generatePaymentReceipt(String name, String location) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 600, 800));

      // Create a gradient background
      final gradient = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(600, 800),
        [Colors.blueAccent, Colors.purpleAccent],
      );
      final paint = Paint()..shader = gradient;
      canvas.drawRect(const Rect.fromLTWH(0, 0, 600, 800), paint);

      // Draw text for receipt
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Payment Receipt\n\n'
              'Dear $name,\n\n'
              'Thank you for your payment to the farmer at $location.\n'
              'We appreciate your support!\n\n'
              'Please keep this receipt for your records.',
          style: const TextStyle(
            color: Colors.white, // Set text color to white
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: 580);
      textPainter.paint(canvas, const Offset(10, 210));

      final picture = recorder.endRecording();
      final img = await picture.toImage(600, 800);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return true;
    } catch (e) {
      debugPrint("Error generating receipt image: $e");
      return false;
    }
  }

  void _showReceiptDialog(String name, String location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Receipt',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Dear $name,\n\n'
            'Thank you for your payment to the farmer at $location.\n'
            'We appreciate your support!\n\n'
            'Please keep this receipt for your records.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
