import 'dart:math';

import 'package:admin/models/recent_file.dart';
import 'package:admin/responsive.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants.dart';

class RecentFiles extends StatelessWidget {
  const RecentFiles({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Users",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical:
                    defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                  ),
                ),
                onPressed: () {},
                icon: Icon(Icons.add),
                label: Text("Add New"),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              // minWidth: 600,
              columns: [
                DataColumn(
                  label: Text("First Name"),
                ),
                DataColumn(
                  label: Text("Last Name"),
                ),
                DataColumn(
                  label: Text("Username"),
                ),
                DataColumn(
                  label: Text("Email"),
                ),
                DataColumn(
                  label: Text("Created"),
                ),
                DataColumn(
                  label: Text('Actions'), // Column for edit/delete buttons
                ),
              ],
              rows: List.generate(
                demoRecentFiles.length,
                (index) => recentFileDataRow(demoRecentFiles[index],context),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

DataRow recentFileDataRow(RecentFile fileInfo, BuildContext context) {
  void _showEditDialog(BuildContext context, RecentFile file) {
    String newTitle = file.title!;
    String newSize = file.size!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => newTitle = value,
              decoration: InputDecoration(hintText: 'Title'),
              // initialValue: newTitle,
            ),
            TextField(
              onChanged: (value) => newSize = value,
              decoration: InputDecoration(hintText: 'Size'),
              // initialValue: newSize,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update the file with newTitle and newSize
              // For now, just print the updated values
              print('Updated file: $newTitle, $newSize');
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, RecentFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete the file
              // For now, just print the deleted file
              print('Deleted file: ${file.title}');
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            // SvgPicture.asset(
            //   fileInfo.icon!,
            //   height: 30,
            //   width: 30,
            // ),
            CircleWithLetter(name: fileInfo.title!),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(fileInfo.title!),
            ),
          ],
        ),
      ),
      DataCell(Text(fileInfo.size!)),
      DataCell(Text(fileInfo.size!)),
      DataCell(Text(fileInfo.date!)),
      DataCell(Text(fileInfo.date!)),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, fileInfo),
              iconSize: 18,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context, fileInfo),
              iconSize: 18,
            ),
          ],
        ),
      ),
    ],
  );
}

class CircleWithLetter extends StatelessWidget {
  final String name;
  final Color textColor;

  const CircleWithLetter({
    Key? key,
    required this.name,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '';
    final randomColor = Color.fromARGB(255, Random.secure().nextInt(256), Random.secure().nextInt(256), Random.secure().nextInt(256));

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: randomColor,
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

