import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

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
    final String apiKey = 'AIzaSyDgBVyxaGNXlI7-50RWv_2OL2ETFRQfR1Q';
    final String databaseUrl =
        'https://scientificdatalogging001-default-rtdb.firebaseio.com/';

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
          'CONTACT_TEMPc': 'Water Temperature',
          'CONTACT_TEMPf': 'Air Temperature',
          'HUMIDITY': 'Humidity',
          'TEMPERATURE': 'Temperature',
          'TURBIDITY': 'Turbidity',
          'pH_value': 'pH',
          'segmentation': 'Segmentation Boxes',
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
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text(
          'Sensor Dashboard',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w100),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 35),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent,
              Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                            attribute: _attributes[0],
                            icon: Icons.water_outlined),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AttributeCard(
                            attribute: _attributes[1], icon: Icons.thermostat),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AttributeCard(
                            attribute: _attributes[4],
                            icon: Icons.remove_red_eye_outlined),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AttributeCard(
                            attribute: _attributes[2],
                            icon: Icons.cloud_outlined),
                        AttributeCard(
                            attribute: _attributes[5],
                            icon: Icons.science_outlined),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AttributeCard(
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
  final IconData? icon; // Icon parameter

  const AttributeCard({Key? key, required this.attribute, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
          height: 120,
          child: GestureDetector(
            onTap:() => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(backgroundColor: Colors.blueAccent.shade100,
                title: Text(attribute.name),
                content: Image.network('https://miro.medium.com/v2/resize:fit:1358/0*4kX7gKz7U-5y4CPu'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK')
                  ),
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
    );
  }
}
