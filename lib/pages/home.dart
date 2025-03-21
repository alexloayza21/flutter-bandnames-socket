import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {
   
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'Megadeth', votes: 4),
    // Band(id: '3', name: 'Slayer', votes: 3),
    // Band(id: '4', name: 'Anthrax', votes: 2),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
    
  }

  _handleActiveBands(dynamic payload){
    bands = (payload as List)
              .map((band) => Band.fromMap(band))
              .toList();

      setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandnames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online // saber si esta conectado
            ? Icon(Icons.check_circle, color: Colors.blue[300],)
            : const Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      body: Column(
        children: [

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index]),
                    ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
   );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(  //barra 
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        print('id : ${band.name}');

        socketService.emit('delete-band', {'id': band.id});
      },
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white),)
        ),
      ),
      
      child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(band.name.substring(0,2)),
          ),
          title: Text(band.name),
          trailing: Text('${band.votes}', style: TextStyle(fontSize: 20),),
          onTap: () {
            print(band.name);
            socketService.socket.emit('vote-band', {'id': band.id});// es mejor mandar un objeto
          },
        ),
    );
  }

  addNewBand(){

    final textController = TextEditingController();

    if(Platform.isAndroid){
      //Android
      return showDialog(  //Dialog ANDROID
        context: context, 
        builder: (_) => AlertDialog(
          title: const Text('New band name:'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text),
              child: const Text('Add'),
            )
          ],
        )
      );
    }

    showCupertinoDialog(  // Dialog IOS
      context: context, 
      builder: (context) => CupertinoAlertDialog(
        title: Text('New Band Name:'),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => addBandToList(textController.text),
            child: Text('Add')
          ),

          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text('Dismiss')
          ),
        ],
      ),
    );

  }

  void addBandToList(String name){
    final socketService = Provider.of<SocketService>(context, listen: false);
    if(name.length > 1){

      socketService.emit('add-band',{'name':name});

    }

    Navigator.pop(context);
  }
  
  Widget _showGraph(){
    Map<String, double> dataMap = {'':0};

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
     });

    return Container( // en mi caso el container era innecesario
      width: double.infinity,
      height: 200,
      child: PieChart(dataMap: dataMap));
  }

}