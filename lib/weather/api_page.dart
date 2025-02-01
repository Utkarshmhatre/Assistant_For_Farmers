import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To load local JSON files
import 'site.dart'; // Import the Site model

class ApiPage extends StatefulWidget {
  const ApiPage({super.key});

  @override
  _ApiPageState createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> {
  // List of Site objects
  List<Site> sites = [];
  int page = 0; // Track the current page of data

  // Function to load the data from the site_ids.json file
  Future<void> loadSiteData() async {
    // Load the site_ids.json file
    String jsonString = await rootBundle.loadString('assets/site_ids.json');
    List<dynamic> jsonResponse = json.decode(jsonString);

    // Simulate pagination by only adding a subset of data
    setState(() {
      int start = page * 5; // Load 5 items per page
      int end = start + 5;
      List<Site> newSites = jsonResponse
          .sublist(start, end)
          .map((siteJson) => Site.fromJson(siteJson))
          .toList();
      sites.addAll(newSites); // Append the new data to the current list
    });

    // Increment the page counter
    page++;
  }

  @override
  void initState() {
    super.initState();
    loadSiteData(); // Load initial set of data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites Data'),
      ),
      body: sites.isEmpty
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator if data is empty
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: sites.length,
                    itemBuilder: (context, index) {
                      Site site = sites[index];
                      return ListTile(
                        title: Text(site.name),
                        subtitle: Text(
                            'City: ${site.city}\nConditions: ${site.conditions ?? "No conditions"}'),
                        trailing: site.avg != null
                            ? Text('Avg: ${site.avg}')
                            : const Text('No avg data'),
                        onTap: () {
                          // You can navigate to a detailed page or show more info
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: loadSiteData, // Load more data when pressed
                  child: const Text("Load More"),
                ),
              ],
            ),
    );
  }
}
