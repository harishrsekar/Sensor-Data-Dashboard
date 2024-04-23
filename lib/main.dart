import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black87,
      title: 'Sensor Dashboard',
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DeviceAttribute> _attributes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    const String apiKey = 'API KEY';
    const String databaseUrl =
        'URL';

    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('$databaseUrl.json?auth=$apiKey'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<DeviceAttribute> attributes = [];

        // Mapping of keys from database to custom names
        final Map<String, String> customNames = {
          'CONTACT_TEMPc': 'Water Temperature (in C)',
          'CONTACT_TEMPf': 'Air Temperature (in F)',
          'HUMIDITY': 'Humidity',
          'TEMPERATURE': 'Temperature',
          'TURBIDITY': 'Turbidity',
          'pH_value': 'pH',
          'segmentation': 'Dissolved Oxygen',
        };

        // Loop through each key-value pair in the data
        data.forEach((key, value) {
          // Check if custom name exists, otherwise use key as name
          String attributeName = customNames[key] ?? key;
          double attributeValue =
              (value as Map<String, dynamic>).values.first.toDouble();
          // Create a DeviceAttribute object and add it to the list
          attributes
              .add(DeviceAttribute(name: attributeName, value: attributeValue));
        });

        setState(() {
          _attributes = attributes;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Sensor Dashboard',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w200),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 35),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AttributeCard(
                            topColor: const Color.fromRGBO(75, 133, 230, 100),
                            bottomColor: const Color.fromRGBO(57, 110, 200, 100),
                            attribute: _attributes[0],
                            icon: Icons.water_outlined),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AttributeCard(
                            topColor: const Color.fromRGBO(53, 107, 197, 100),
                            bottomColor: const Color.fromRGBO(45, 81, 147, 100),
                            attribute: _attributes[1],
                            icon: Icons.thermostat),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AttributeCard(
                            topColor: const Color.fromRGBO(43,79,145, 100),
                            bottomColor: const Color.fromRGBO(29,60,107, 100),
                            attribute: _attributes[4],
                            icon: Icons.remove_red_eye_outlined),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AttributeCard(
                            topColor: const Color.fromRGBO(28,55,99, 100),
                            bottomColor: const Color.fromRGBO(28,55,99, 100),
                            attribute: _attributes[2],
                            icon: Icons.cloud_outlined),
                        AttributeCard(
                            topColor: const Color.fromRGBO(28,55,99, 100),
                            bottomColor: const Color.fromRGBO(28,55,99, 100),
                            attribute: _attributes[5],
                            icon: Icons.science_outlined),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AttributeCard(
                            topColor: const Color.fromRGBO(28,55,99, 100),
                            bottomColor: const Color.fromRGBO(14,26,50, 100),
                            attribute: _attributes[6],
                            icon: Icons.landscape_outlined),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class DeviceAttribute {
  final String name;
  final double value;

  DeviceAttribute({required this.name, required this.value});
}

class AttributeCard extends StatelessWidget {
  final DeviceAttribute attribute;
  final IconData? icon; // I
  final Color topColor;
  final Color bottomColor; // con parameter

  const AttributeCard(
      {Key? key,
      required this.attribute,
      this.icon,
      required this.topColor,
      required this.bottomColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SizedBox(
          height: 120,
          child: GestureDetector(
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Color.fromRGBO(131,210,225,0),
                  ),
                  borderRadius: BorderRadius.circular(10)),
                backgroundColor: const Color.fromRGBO(131,210,225, 40),
                title: Text(attribute.name, style: const TextStyle(fontSize: 22),),
                content: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Image.network(fit: BoxFit.fitHeight,
                      'https://i.imgur.com/NXt2eJb.png'),
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(context, 'Close'),
                      child: const Text('Close',style: TextStyle(fontSize: 22, fontWeight: FontWeight.w200),)),
                ],
              ),
            ) /*() async {await Get.dialog(Text('data'));}*/,
            child: Card(
              shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.white60,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              color: Colors.white.withOpacity(0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                        colors: [topColor, bottomColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: Center(
                  child: ListTile(
                    leading: icon != null
                        ? Icon(
                            icon,
                            color: Colors.white,
                            size: 40,
                          )
                        : null,
                    // Show icon if provided
                    title: Text(attribute.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w300)),
                    subtitle: Text(attribute.value.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
