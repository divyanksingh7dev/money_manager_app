import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:get_storage/get_storage.dart';

double gain = 0;
double loss = 0;
List descriptionAppend = [];
List dateAppend = [];
List moneyAppend = [];
final storage = GetStorage();

void main() async {
  await GetStorage.init();
  initVal();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  final DateTime initialDate = DateTime.now();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime? selectedDate;
  int? selectedYear;
  int? selectedMonth;
  TextEditingController addDescriptionG = TextEditingController();
  TextEditingController addMoneyG = TextEditingController();
  TextEditingController addDescriptionL = TextEditingController();
  TextEditingController addMoneyL = TextEditingController();

  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedYear = DateTime.now().year;
    selectedMonth = DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Money Manager"),
        ),
        body: Column(children: [
          Row(
            children: [
              //const Spacer(),
              Expanded(
                child: Card(
                    color: const Color.fromARGB(85, 0, 255, 0),
                    child: Column(
                        children: [const Text("Total Money"), Text("$gain")])),
                flex: 4,
              ),
              //const Spacer(),
              Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero, // Set this
                        padding: EdgeInsets.zero, // and this
                      ),
                      child: Column(
                        children: [
                          Center(child: Text(monthSelector(selectedMonth))),
                          Center(
                            child: Text((selectedYear).toString()),
                          )
                        ],
                      ),
                      onPressed: () {
                        showMonthPicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 1, 5),
                          lastDate: DateTime(DateTime.now().year + 1, 9),
                          initialDate: selectedDate ?? widget.initialDate,
                          locale: Locale("en"),
                        ).then((date) {
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                              if (selectedDate != Null) {
                                selectedMonth = selectedDate?.month;
                                selectedYear = selectedDate?.year;
                              }
                            });
                          }
                        });
                      }),
                  flex: 2),
              Expanded(
                child: Card(
                    color: const Color.fromARGB(85, 255, 0, 0),
                    child: Column(
                        children: [const Text("Total Spent"), Text("$loss")])),
                flex: 4,
              ),
              //const Spacer()
            ],
          ),
          //Spacer(),
          Expanded(
              child: Container(
            //color: Color.fromARGB(255, 0, 0, 0),
            child: ListView.builder(
              itemCount: moneyAppend.length,
              itemBuilder: (BuildContext context, int index) {
                if (dateAppend[index].substring(5, dateAppend[index].length) ==
                    "$selectedMonth / $selectedYear") {
                  String tempDesc = descriptionAppend[index],
                      tempDate = dateAppend[index],
                      tempMoney = moneyAppend[index];
                  int r, g, b, a;
                  if (tempMoney[0] == '+') {
                    r = 0;
                    g = 255;
                    b = 0;
                    a = 85;
                  } else {
                    r = 255;
                    g = 0;
                    b = 0;
                    a = 85;
                  }
                  return Card(
                    color: Color.fromARGB(a, r, g, b),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                              children: [Text("$tempDesc"), Text("$tempDate")],
                            ),
                            flex: 8),
                        Expanded(
                          child: Text("$tempMoney"),
                          flex: 2,
                        ),
                        IconButton(
                            onPressed: () {
                              String tempMoney = moneyAppend[index];
                              double delMoney =
                                  double.parse(tempMoney.substring(1));
                              setState(() {
                                if (tempMoney[0] == '+') {
                                  gain -= delMoney;
                                } else {
                                  loss -= delMoney;
                                  gain += delMoney;
                                }
                                moneyAppend.removeAt(index);
                                descriptionAppend.removeAt(index);
                                dateAppend.removeAt(index);

                                setStorage(storage, descriptionAppend,
                                    dateAppend, moneyAppend, gain, loss);
                              });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Color.fromARGB(255, 33, 149, 243),
                            )),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text("Nothing To Display"));
                }
              },
            ),
          )),
          //Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Spacer(),
              Expanded(
                child: ElevatedButton(
                    onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Add Gain'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                    controller: addDescriptionG,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Description',
                                    )),
                                SizedBox(height: 10),
                                TextField(
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    controller: addMoneyG,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Money',
                                    ))
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => setState(() {
                                  addDescriptionG.clear();
                                  addMoneyG.clear();
                                  Navigator.pop(context, 'Cancel');
                                }),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => setState(() {
                                  String desc = addDescriptionG.text;
                                  double money = double.parse(addMoneyG.text);

                                  int tempDay = DateTime.now().day;
                                  int tempMonth = DateTime.now().month;
                                  int tempYear = DateTime.now().year;

                                  gain += money;
                                  addDescriptionG.clear();
                                  addMoneyG.clear();

                                  descriptionAppend.add(desc);
                                  moneyAppend.add("+$money");
                                  dateAppend
                                      .add("$tempDay / $tempMonth / $tempYear");

                                  setStorage(storage, descriptionAppend,
                                      dateAppend, moneyAppend, gain, loss);

                                  Navigator.pop(context, 'OK');
                                }),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                    child: Text("Gain")),
                flex: 4,
              ),
              Spacer(),
              Expanded(
                child: ElevatedButton(
                    onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Add Loss'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                    controller: addDescriptionL,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Description',
                                    )),
                                SizedBox(height: 10),
                                TextField(
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    controller: addMoneyL,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Money',
                                    ))
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => setState(() {
                                  addDescriptionL.clear();
                                  addMoneyL.clear();
                                  Navigator.pop(context, 'Cancel');
                                }),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => setState(() {
                                  String desc = addDescriptionL.text;
                                  double money = double.parse(addMoneyL.text);

                                  int tempDay = DateTime.now().day;
                                  int tempMonth = DateTime.now().month;
                                  int tempYear = DateTime.now().year;

                                  gain -= money;
                                  loss += money;
                                  addDescriptionL.clear();
                                  addMoneyL.clear();

                                  descriptionAppend.add(desc);
                                  moneyAppend.add("-$money");
                                  dateAppend
                                      .add("$tempDay / $tempMonth / $tempYear");

                                  setStorage(storage, descriptionAppend,
                                      dateAppend, moneyAppend, gain, loss);

                                  Navigator.pop(context, 'OK');
                                }),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                    child: Text("Loss")),
                flex: 4,
              ),
              Spacer()
            ],
          )
        ]),
      ),
    );
  }
}

void setStorage(s, des, dat, mon, ga, lo) {
  s.erase();
  s.write("description", des);
  s.write("date", dat);
  s.write("money", mon);
  s.write("gain", ga);
  s.write("loss", lo);
}

void initVal() {
  if (storage.hasData("gain")) {
    gain = storage.read("gain");
  }
  if (storage.hasData("loss")) {
    loss = storage.read("loss");
  }
  if (storage.hasData("description")) {
    descriptionAppend = storage.read("description");
  }
  if (storage.hasData("date")) {
    dateAppend = storage.read("date");
  }
  if (storage.hasData("money")) {
    moneyAppend = storage.read("money");
  }
}

String monthSelector(int? month) {
  switch (month) {
    case 1:
      {
        return "JANUARY";
      }
      break;
    case 2:
      {
        return "FEBRUARY";
      }
      break;
    case 3:
      {
        return "MARCH";
      }
      break;
    case 4:
      {
        return "APRIL";
      }
      break;
    case 5:
      {
        return "MAY";
      }
      break;
    case 6:
      {
        return "JUNE";
      }
      break;
    case 7:
      {
        return "JULY";
      }
      break;
    case 8:
      {
        return "AUGUST";
      }
      break;
    case 9:
      {
        return "SEPTEMBER";
      }
      break;
    case 10:
      {
        return "OCTOBER";
      }
      break;
    case 11:
      {
        return "NOVEMBER";
      }
      break;
    case 12:
      {
        return "DECEMBER";
      }
      break;
  }
  return "0";
}
