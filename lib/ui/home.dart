import '../root/file.dart';
import '../models/consumo.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Consumo> consumos = [];

  double quantidade = 0;
  double peso = 0;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void carregarDados() async {
    String conteudo = await GerenciarArquivo.abrir();

    if (conteudo.isEmpty) {
      return;
    }

    List<String> linhas = conteudo.split('\n');

    setState(() {
      consumos = linhas
          .where((linha) => linha.trim().isNotEmpty)
          .map((linha) => Consumo.fromCSV(linha))
          .toList();
    });
  }

  void salvarDados() {
    String conteudo = consumos.map((consumo) => consumo.toCSV()).join('\n');
    GerenciarArquivo.salvar(conteudo);
  }

  double totalDoDia() {
    String hoje = DateTime.now().toString().substring(0, 10);

    return consumos
        .where((consumo) => consumo.data.substring(0, 10) == hoje)
        .fold(0, (total, consumo) => total + consumo.quantidadeEmMl);
  }

  double metaDiaria() {
    if (consumos.isEmpty) {
      return 0;
    }

    return consumos.last.pesoAtualKg * 35;
  }

  double porcentagemMeta() {
    double meta = metaDiaria();

    if (meta == 0) {
      return 0;
    }

    return (totalDoDia() / meta) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Bebi água"),
        actions: [
          GestureDetector(
            onTap: () {
              cadastrar();
            },
            child: Container(
              margin: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: Icon(
                Icons.add,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Consumo de hoje",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${totalDoDia().toStringAsFixed(0)} ml",
                    style: TextStyle(fontSize: 28),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${porcentagemMeta().toStringAsFixed(1)}% da meta diária",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: consumos.length,
              itemBuilder: (context, i) {
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    onTap: () {
                      editar(i);
                    },
                    title: Text(
                      "${consumos[i].quantidadeEmMl.toStringAsFixed(0)} ml",
                    ),
                    subtitle: Text(
                      "${consumos[i].data} | Peso: ${consumos[i].pesoAtualKg.toStringAsFixed(1)} kg",
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        excluir(i);
                      },
                      child: Icon(Icons.delete),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void cadastrar() {
    quantidade = 0;
    peso = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Novo consumo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Quantidade em ml",
              ),
              onChanged: (value) {
                quantidade = double.tryParse(value) ?? 0;
              },
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Peso atual em kg",
              ),
              onChanged: (value) {
                peso = double.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (quantidade <= 0 || peso <= 0) {
                return;
              }

              Navigator.of(context).pop();

              String data =
                  DateTime.now().toString().substring(0, 16);

              setState(() {
                consumos.add(
                  Consumo(
                    data: data,
                    quantidadeEmMl: quantidade,
                    pesoAtualKg: peso,
                  ),
                );
              });

              salvarDados();
            },
            child: Text("Cadastrar"),
          ),
        ],
      ),
    );
  }

  void editar(int indice) {
    quantidade = consumos[indice].quantidadeEmMl;
    peso = consumos[indice].pesoAtualKg;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Alterar consumo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: quantidade.toString(),
              ),
              decoration: InputDecoration(
                hintText: "Quantidade em ml",
              ),
              onChanged: (value) {
                quantidade = double.tryParse(value) ?? 0;
              },
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: peso.toString(),
              ),
              decoration: InputDecoration(
                hintText: "Peso atual em kg",
              ),
              onChanged: (value) {
                peso = double.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              setState(() {
                consumos[indice] = Consumo(
                  data: consumos[indice].data,
                  quantidadeEmMl: quantidade,
                  pesoAtualKg: peso,
                );
              });

              salvarDados();
            },
            child: Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void excluir(int indice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Excluir registro"),
        content: Text("Confirma a exclusão deste registro?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              setState(() {
                consumos.removeAt(indice);
              });

              salvarDados();
            },
            child: Text("Ok"),
          ),
        ],
      ),
    );
  }
}