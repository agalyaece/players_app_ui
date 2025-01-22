import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:country_picker/country_picker.dart';

import 'package:players_app/backend_config/config.dart';
import 'package:players_app/models/player_details.dart';
import 'package:players_app/screens/home/players.dart';

class EditPlayer extends StatefulWidget {
  final PlayerDetails data;

  const EditPlayer({super.key, required this.data});
  @override
  State<EditPlayer> createState() {
    return _EditPlayerState();
  }
}

class _EditPlayerState extends State<EditPlayer> {
  final _formKey = GlobalKey<FormState>();
  String? _enteredName;
  int? _enteredAge;
  String? _selectedCountryCode;
  var _isSending = false;

  @override
  void initState() {
    super.initState();
    _enteredName = widget.data.name;
    _enteredAge = widget.data.age;
    _selectedCountryCode = widget.data.born;
  }

  void _updatePlayer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSending = true;
    });
    _formKey.currentState!.save();

    final url = Uri.parse(updatePlayerUrl(widget.data.id));
    final response = await http.patch(
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Success", style: TextStyle(color: Colors.green)),
            content: const Text(
              " updating details  Successful",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, const PlayersScreen());
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error", style: TextStyle(color: Colors.red)),
            content: const Text("Failed to update details",
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

  List<Country> get countryList {
    return CountryService().getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                initialValue: _enteredName,
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
                initialValue: _enteredAge?.toString(),
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
                                _selectedCountryCode = widget.data.born;
                                _enteredAge = widget.data.age;
                                _enteredName = widget.data.name;
                              });
                            },
                      child: const Text("Reset")),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSending ? null : _updatePlayer,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
