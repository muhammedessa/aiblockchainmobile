import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

//for ethereum contract blockchain
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:path/path.dart' show join, dirname;
import 'package:web_socket_channel/io.dart';



void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: MyApp(),
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading = false;


  //for initialize the Ethereum client
  final String rpcUrl = 'http://192.168.0.102:7545';
  final String wsUrl = 'ws://192.168.0.102:7545';
  final String privateKey = '9a770982537f5489d3e5a1082d57ea2a1354e2893ba996132e52347f2af82408';
  final EthereumAddress contractAddr = EthereumAddress.fromHex('0x4ab1bE51D8054b698ACaEcB2d5FE77621fB5952e');
  final EthereumAddress receiver =  EthereumAddress.fromHex('0x2268e375a2787A74c750518e96144FecAA65F7e0');

  Future<dynamic> myData() async{
    final httpClient =new Client();
    final client =new  Web3Client(rpcUrl, httpClient, enableBackgroundIsolate: true);
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final ownAddress = await credentials.extractAddress();
    //final contract = DeployedContract(ContractAbi.fromJson('[ { "inputs": [], "payable": false, "stateMutability": "nonpayable", "type": "constructor" }, { "anonymous": false, "inputs": [ { "indexed": true,"internalType": "address", "name": "_from",  "type": "address"  },  { "indexed": true,  "internalType": "address", "name": "_to", "type": "address" }, { "indexed": false,  "internalType": "uint256", "name": "_value", "type": "uint256"} ],  "name": "Transfer", "type": "event"  }, {  "constant": false, "inputs": [ { "internalType": "address", "name": "receiver", "type": "address" },  {  "internalType": "uint256",  "name": "amount", "type": "uint256"  }],  "name": "sendCoin", "outputs": [ { "internalType": "bool",  "name": "sufficient", "type": "bool" } ],  "payable": false,  "stateMutability": "nonpayable", "type": "function" },{  "constant": true, "inputs": [ { "internalType": "address", "name": "addr",  "type": "address" }  ],  "name": "getBalanceInEth",  "outputs": [ {  "internalType": "uint256",  "name": "", "type": "uint256" } ],  "payable": false,  "stateMutability": "view", "type": "function" }, {  "constant": true,  "inputs": [  {  "internalType": "address",  "name": "addr", "type": "address" } ], "name": "getBalance", "outputs": [ {"internalType": "uint256",  "name": "",  "type": "uint256"  } ], "payable": false, "stateMutability": "view", "type": "function" } ]', 'MetaCoin'), contractAddr);

    final abiCode = '[ { "inputs": [], "payable": false, "stateMutability": "nonpayable", "type": "constructor" }, { "anonymous": false, "inputs": [ { "indexed": true,"internalType": "address", "name": "_from",  "type": "address"  },  { "indexed": true,  "internalType": "address", "name": "_to", "type": "address" }, { "indexed": false,  "internalType": "uint256", "name": "_value", "type": "uint256"} ],  "name": "Transfer", "type": "event"  }, {  "constant": false, "inputs": [ { "internalType": "address", "name": "receiver", "type": "address" },  {  "internalType": "uint256",  "name": "amount", "type": "uint256"  }],  "name": "sendCoin", "outputs": [ { "internalType": "bool",  "name": "sufficient", "type": "bool" } ],  "payable": false,  "stateMutability": "nonpayable", "type": "function" },{  "constant": true, "inputs": [ { "internalType": "address", "name": "addr",  "type": "address" }  ],  "name": "getBalanceInEth",  "outputs": [ {  "internalType": "uint256",  "name": "", "type": "uint256" } ],  "payable": false,  "stateMutability": "view", "type": "function" }, {  "constant": true,  "inputs": [  {  "internalType": "address",  "name": "addr", "type": "address" } ], "name": "getBalance", "outputs": [ {"internalType": "uint256",  "name": "",  "type": "uint256"  } ], "payable": false, "stateMutability": "view", "type": "function" } ]';
    final contract = DeployedContract(ContractAbi.fromJson(abiCode, 'MetaCoin'), contractAddr);

    final address = await credentials.extractAddress();
    print(address.hexEip55);
    print(await client.getBalance(address));

//    await client.sendTransaction(
//      credentials,
//      Transaction(
//        to: EthereumAddress.fromHex('0x137EcCfb48F6BC21fa6310f7907932614825EEcE'),
//        gasPrice: EtherAmount.inWei(BigInt.one),
//        maxGas: 100000,
//        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
//      ),
//      fetchChainIdFromNetworkId: false,
//    );

    final sendFunction = contract.function('sendCoin');
    final balanceFunction = contract.function('getBalance');
    final balance = await client.call(
        contract: contract, function: balanceFunction, params: [ownAddress]);
    print('We have ${balance.first} MetaCoins');

    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: sendFunction,
        parameters: [receiver ,balance.first],
      ),
    );


    await client.dispose();

  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Machine Learning'),
      ),
      body: _loading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Container() : Image.file(_image),
            SizedBox(
              height: 20,
            ),
            _outputs != null
                ? Text(
              "${_outputs[0]["label"]}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
            )
                : Container(),

          ],
        ),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
      ),
    );
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });

      myData().whenComplete(() => {classifyImage(image)}) ;

  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }





}