import 'package:flutter/material.dart';
import 'package:hitung_keuangan/database/DatabaseHelper.dart';
import 'package:hitung_keuangan/decoration/format_rupiah.dart';
import 'package:hitung_keuangan/model/model_database.dart';
import 'package:hitung_keuangan/pemasukan/page_input_pemasukan.dart';

class PagePemasukan extends StatefulWidget {
  const PagePemasukan({Key? key}) : super(key: key);

  @override
  State<PagePemasukan> createState() => _PagePemasukanState();
}

class _PagePemasukanState extends State<PagePemasukan> {
  List<ModelDatabase> listPemasukan = [];
  DatabaseHelper databaseHelper = DatabaseHelper();
  int strJmlUang = 0;
  int strCheckDatabase = 0;

  @override
  void initState() {
    super.initState();
    getDatabase();
    getJmlUang();
    getAllData();
  }

  //cek database ada data atau tidak
  Future<void> getDatabase() async {
    var checkDB = await databaseHelper.cekDataPemasukan();
    setState(() {
      if (checkDB == 0) {
        strCheckDatabase = 0;
        strJmlUang = 0;
      } else {
        strCheckDatabase = checkDB!;
      }
    });
  }

  //cek jumlah total uang
  Future<void> getJmlUang() async {
    var checkJmlUang = await databaseHelper.getJmlPemasukan();
    setState(() {
      if (checkJmlUang == 0) {
        strJmlUang = 0;
      } else {
        strJmlUang = checkJmlUang;
      }
    });
  }

  //get data untuk menampilkan ke listview
  Future<void> getAllData() async {
    var listData = await databaseHelper.getDataPemasukan();
    setState(() {
      listPemasukan.clear();
      listData!.forEach((kontak) {
        listPemasukan.add(ModelDatabase.fromMap(kontak));
      });
    });
  }

  //untuk hapus data berdasarkan Id
  Future<void> deleteData(ModelDatabase modelDatabase, int position) async {
    await databaseHelper.deletePemasukan(modelDatabase.id!);
    setState(() {
      getJmlUang();
      getDatabase();
      listPemasukan.removeAt(position);
    });
  }

  //untuk insert data baru
  Future<void> openFormCreate() async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => PageInputPemasukan()));
    if (result == 'save') {
      await getAllData();
      await getJmlUang();
      await getDatabase();
    }
  }

  //untuk edit data
  Future<void> openFormEdit(ModelDatabase modelDatabase) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PageInputPemasukan(modelDatabase: modelDatabase)));
    if (result == 'update') {
      await getAllData();
      await getJmlUang();
      await getDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(10),
              clipBehavior: Clip.antiAlias,
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              child: ListTile(
                title: Text('Total Pemasukan Bulan Ini',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(CurrencyFormat.convertToIdr(strJmlUang),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ),
            ),
            strCheckDatabase == 0
                ? Container(
                    padding: EdgeInsets.only(top: 200),
                    child: Text(
                        'Ups, belum ada pemasukan.\nYuk catat pemasukan Kamu!',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)))
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: listPemasukan.length,
                    itemBuilder: (context, index) {
                      ModelDatabase modeldatabase = listPemasukan[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        clipBehavior: Clip.antiAlias,
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        child: ListTile(
                          title: Text('${modeldatabase.keterangan}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                ),
                                child: Text('Jumlah Uang: ' +
                                    CurrencyFormat.convertToIdr(
                                        int.parse(modeldatabase.jml_uang.toString())),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 8
                                ),
                                child: Text('Tanggal: ${modeldatabase.tanggal}',
                                    style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black)),
                              ),
                            ],
                          ),
                          trailing: FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      openFormEdit(modeldatabase);
                                    },
                                    icon: Icon(Icons.edit, color: Colors.black,)
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red,),
                                  onPressed: () {
                                    AlertDialog hapus = AlertDialog(
                                      title: Text('Hapus Data',
                                          style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black)),
                                      content: Container(
                                        height: 20,
                                        child: Column(
                                          children: [
                                            Text('Yakin ingin menghapus data ini?',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black))
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              deleteData(modeldatabase, index);
                                              Navigator.pop(context);
                                            },
                                            child: Text('Ya',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black))),
                                        TextButton(
                                          child: Text('Tidak',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                    showDialog(
                                        context: context,
                                        builder: (context) => hapus);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          openFormCreate();
        },
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Pemasukan',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}
