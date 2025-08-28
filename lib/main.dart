
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyCryptoApp());

class MyCryptoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Crypto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CryptoHomePage(),
    );
  }
}

class CryptoHomePage extends StatefulWidget {
  @override
  _CryptoHomePageState createState() => _CryptoHomePageState();
}

class _CryptoHomePageState extends State<CryptoHomePage> {
  Map<String, dynamic>? data;
  bool loading = true;

  Future<void> fetchData() async {
    setState(() => loading = true);
    final res = await http.get(Uri.parse('https://apimycrypto.4mir.ir'));
    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Widget buildSection(String title, Map items, {bool isCrypto = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...items.entries.map((entry) {
          final item = entry.value;
          final direction = item['change']['direction'];
          final emoji = direction == 'up' ? '🟢' : direction == 'down' ? '🔴' : '🔵';
          final price = isCrypto ? '\${item['price']}\$' : item['price'];
          return Card(
            child: ListTile(
              title: Text(item['name']),
              subtitle: Text('\$price (\${item['change']['value']}%)'),
              trailing: Text(emoji, style: TextStyle(fontSize: 20)),
            ),
          );
        }).toList(),
        SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Crypto')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data?['fiat'] != null)
                      buildSection('💵 ارزها', data!['fiat']),
                    if (data?['gold'] != null)
                      buildSection('🥇 طلا و سکه', data!['gold']),
                    if (data?['crypto'] != null)
                      buildSection('💰 کریپتو', data!['crypto'], isCrypto: true),
                    SizedBox(height: 10),
                    Text('🔗 Powered by: \${data?['poweredby'] ?? ''}',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchData,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
