import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Clients extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(dynamic)? onClientTap;
  final dynamic selectedClient;
  const Clients({this.onClose, this.onClientTap, this.selectedClient});

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final auth = FirebaseAuth.instance;
    final firebaseFirestore = FirebaseFirestore.instance.collection('Admin');

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Search bar and close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Search Client",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
              child: TextField(
                controller: searchController,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                  ),
                  hintText: "Type client name or number...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 0,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "Clients",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List of clients
          Expanded(
            child: StreamBuilder(
              stream: firebaseFirestore
                  .doc(auth.currentUser!.uid)
                  .collection('ClientCollection')
                  .snapshots(),
              builder: (context, snapshot) {
                String formatDate(dynamic date) {
                  try {
                    if (date is DateTime) {
                      return DateFormat('dd MMM yyyy').format(date);
                    } else if (date is String) {
                      if (date.contains('-')) {
                        return DateFormat(
                          'dd MMM yyyy',
                        ).format(DateTime.parse(date));
                      } else if (date.contains('/')) {
                        final parts = date.split('/');
                        if (parts.length == 3) {
                          final d = DateTime(
                            int.parse(parts[2]),
                            int.parse(parts[1]),
                            int.parse(parts[0]),
                          );
                          return DateFormat('dd MMM yyyy').format(d);
                        }
                      }
                    }
                  } catch (_) {}
                  return date.toString(); // fallback
                }

                int calculateRemainingDays(dynamic endDate) {
                  try {
                    DateTime end;
                    if (endDate is DateTime) {
                      end = endDate;
                    } else {
                      end = DateTime.parse(endDate.toString());
                    }
                    final now = DateTime.now();
                    return end.difference(now).inDays;
                  } catch (_) {
                    return 0;
                  }
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot == null || !snapshot.hasData) {
                  return Center(
                    child: Text(
                      'No Data Found',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '❌ Error: ${snapshot.error}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }
                var clients = snapshot.hasData ? snapshot.data!.docs : [];
                final query = searchController.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? clients
                    : clients.where((c) {
                        final name = (c['name'] ?? '').toString().toLowerCase();
                        final contact = (c['contact'] ?? '')
                            .toString()
                            .toLowerCase();
                        final whatsapp = (c['whatsapp'] ?? '')
                            .toString()
                            .toLowerCase();
                        // Search by name, contact, or whatsapp number
                        return name.contains(query) || contact.contains(query);
                      }).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No clients found.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    var client = filtered[index];
                    final joined = formatDate(client['startDate']);
                    final end = formatDate(client['endDate']);
                    final remaining = calculateRemainingDays(client['endDate']);

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                        left: 8,
                        right: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          child: Icon(
                            Icons.person,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        title: Text(
                          client['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            "Remaining: ${remaining >= 0 ? '$remaining days' : 'Expired'} \nJoined: $joined | End: $end\n",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withOpacity(0.5),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        onTap: () {
                          if (widget.onClientTap != null) {
                            widget.onClientTap!(client);
                          }
                        },
                        selected:
                            widget.selectedClient != null &&
                            widget.selectedClient['id'] == client['id'],
                        selectedTileColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.08),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
