import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hava_durumu/search_page.dart';
import 'package:http/http.dart' as http;
import "dart:convert";
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = "";
  int sicaklik = 20;
  var locationData;
  var locationData2;
  var title;
  Position position;
  var woeid;
  var temperature0;
   String arkaPlan0 = "c";
  var tarih0;
  List <int> temp= List(5);
  List <String> ark= List(5);
  List <String> tarih= List(5);


  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (error) {
      print("Şu hata oluştu $error");
    } finally {
// ne olursa olsun burdaki kodları çalıştır
    }

    print(position);
  }

  Future<void> getLocationData() async {
    locationData = await http
        .get("https://www.metaweather.com/api/location/search/?query=$sehir");
    print(locationData);
    var locationDataParsed = jsonDecode(locationData.body);
    setState(() {
      title = locationDataParsed[0]["title"];
      woeid = locationDataParsed[0]["woeid"];
    });
  }

  Future<void> getLocationTemp() async {
    locationData2 =
        await http.get("https://www.metaweather.com/api/location/$woeid/");
    print(locationData2);
    var locationDataParsed2 = jsonDecode(locationData2.body);

    setState(() {
      temperature0 = locationDataParsed2["consolidated_weather"][0]["the_temp"].round();
      arkaPlan0=
          locationDataParsed2["consolidated_weather"][0]["weather_state_abbr"];
      tarih0 = locationDataParsed2["consolidated_weather"][0]["applicable_date"];

     for(int i =0; i<temp.length; i++ ){
       temp[i]=locationDataParsed2["consolidated_weather"][i+1]["the_temp"].round();
       tarih[i]=locationDataParsed2["consolidated_weather"][i+1]["applicable_date"];
       ark[i]=locationDataParsed2["consolidated_weather"][0]["weather_state_abbr"];
     }

    });
  }

  Future<void> getDataFromApi() async {
    await getDevicePosition();
    await getLocationDataLatLong();
    getLocationTemp();
  }

  Future<void> getDataFromApiByCity() async {
    await getLocationData();
    getLocationTemp();
  }

  Future<void> getLocationDataLatLong() async {
    locationData = await http.get(
        "https://www.metaweather.com/api/location/search/?lattlong=${position.latitude},${position.longitude}");
    print(locationData);
    var locationDataParsed = jsonDecode(utf8.decode(locationData.bodyBytes));
    setState(() {
      woeid = locationDataParsed[0]["woeid"];
      title = locationDataParsed[0]["title"];
    });
  }

  @override
  void initState() {
    getDataFromApi();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/$arkaPlan0.jpg"),
        ),
      ),
      child: temperature0 == null
          ? Center(
              child: SpinKitCubeGrid(
                color: Colors.yellow,
              ),
            )
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Image.network(
                          "https://www.metaweather.com/static/img/weather/png/64/$arkaPlan0.png"),
                      width: 30,
                      height: 30,
                    ),
                    Text(
                      "$temperature0",
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                color: Colors.black38,
                                blurRadius: 5,
                                offset: Offset(-3, 3))
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$title",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
                                Shadow(
                                    color: Colors.black38,
                                    blurRadius: 5,
                                    offset: Offset(-12, 3))
                              ]),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            sehir = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()));

                            getDataFromApiByCity();
                            setState(() {
                              sehir = sehir;
                            });
                          },
                        ),
                      ],
                    ),
                    kartBuilder(context),
                  ],
                ),
              ),
            ),
    );
  }

  Container kartBuilder(BuildContext context) {
    return Container(
                    height: 120,
                    width: (MediaQuery.of(context).size.width) * .9,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return TahminKartlari(
                          arkaPlan: ark[index],
                          temperature: temp[index],
                          tarih: tarih[index],
                        );
                      },
                    ),
                  );
  }
}

class TahminKartlari extends StatelessWidget {
  String arkaPlan;
  var temperature;
  var tarih;

  TahminKartlari({this.arkaPlan, this.temperature, this.tarih});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 2,
      child: Container(
        width: 100,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://www.metaweather.com/static/img/weather/png/64/$arkaPlan.png",
              height: 50,
              width: 50,
            ),
            Text("$temperature"),
            Text("$tarih"),
          ],
        ),
      ),
    );
  }
}
