import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:country_picker/country_picker.dart';

import 'package:players_app/backend_config/config.dart';
import 'package:players_app/screens/home/players.dart';

class AddPlayer extends StatefulWidget {
  const AddPlayer({super.key});

  @override
  State<AddPlayer> createState() {
    return _AddPlayerState();
  }
}

class _AddPlayerState extends State<AddPlayer> {
  final _formKey = GlobalKey<FormState>();

  var _enteredName = "";
  int _enteredAge = 0;
  String? _selectedCountryCode;
  var _isSending = false;

  void _addPlayer() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = Uri.parse(addPlayerUrl);
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": _enteredName,
          "age": _enteredAge,
          "born": _selectedCountryCode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newItem = json.decode(response.body);

        if (!context.mounted) {
          return;
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  const Text("Success", style: TextStyle(color: Colors.green)),
              content: Text(
                  json.decode(response.body)['message'] ??
                      "The addition was Successful",
                  style: TextStyle(color: Colors.white)),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, newItem);
                    Navigator.pop(context, const PlayersScreen());
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        
        setState(() {
          _isSending = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error", style: TextStyle(color: Colors.red)),
              content: Text(
                  json.decode(response.body)['message'] ??
                      "Failed to add player. Please try again.",
                  style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Players"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter valid characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                maxLength: 2,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter valid Number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredAge = int.tryParse(value!) ?? 0;
                },
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  hint: Text('Select Country'),
                  value: _selectedCountryCode,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCountryCode = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a team';
                    }
                    return null;
                  },
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                  isExpanded: true,
                  items: countryList
                      .map<DropdownMenuItem<String>>((Country country) {
                    return DropdownMenuItem<String>(
                      value: country.countryCode,
                      child: Text('${country.name} (${country.countryCode})'),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                              setState(() {
                                _selectedCountryCode = null;
                              });
                            },
                      child: const Text("Reset")),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSending ? null : _addPlayer,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Country> get countryList {
    return CountryService().getAll();
  }
}
