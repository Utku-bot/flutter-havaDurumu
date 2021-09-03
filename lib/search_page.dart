import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

var sehirController = TextEditingController();

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/search.jpg"),
        ),
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var response = await http.get(
                "https://www.metaweather.com/api/location/search/?query=${sehirController.text}");
            jsonDecode(response.body).isEmpty?
            CoolAlert.show(
              title: "HATA",
              context: context,
              type: CoolAlertType.error,
              text: "Yanlış şehir adı girildi",
            ):



            Navigator.pop(context, sehirController.text);
          },
        ),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: sehirController,
                  decoration: InputDecoration(
                    hintText: "Şehir Giriniz",
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  style: TextStyle(fontSize: 26),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(sehirController.text),
            ],
          ),
        ),
      ),
    );
  }
}
