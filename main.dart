import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const BhograiMart());

class BhograiMart extends StatelessWidget {
  const BhograiMart({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Bhograi Mart',
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF137333))),
    home: const Home(),
  );
}

class Item {
  final String name; final int price; final IconData icon;
  const Item(this.name, this.price, this.icon);
}

const items = [
  Item('Tomato', 25, Icons.local_florist),
  Item('Potato', 22, Icons.spa),
  Item('Onion', 28, Icons.eco),
  Item('Rice', 82, Icons.grain),
  Item('Cooking Oil', 110, Icons.water_drop),
  Item('Milk', 58, Icons.local_drink),
  Item('Bread', 40, Icons.breakfast_dining),
  Item('Tata Salt', 20, Icons.shopping_bag),
];

class Home extends StatefulWidget {
  const Home({super.key});
  @override State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Map<Item,int> cart = {};
  String pin = '756038';
  int get count => cart.values.fold(0, (a,b)=>a+b);
  int get subtotal => cart.entries.fold(0, (a,e)=>a+e.key.price*e.value);

  void add(Item i) => setState(()=>cart[i]=(cart[i]??0)+1);
  void remove(Item i) => setState(() {
    final q=cart[i]??0;
    if(q<=1) cart.remove(i); else cart[i]=q-1;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Bhograi Mart', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [Padding(padding: const EdgeInsets.only(right: 8), child: Center(child: Badge(label: Text('$count'), isLabelVisible: count>0, child: const Icon(Icons.shopping_cart))))],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Fresh groceries at your doorstep', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.location_on),
          const SizedBox(width: 8),
          const Text('Delivery PIN: '),
          DropdownButton<String>(
            value: pin,
            items: const ['756036','756037','756038','756085'].map((x)=>DropdownMenuItem(value:x, child:Text(x))).toList(),
            onChanged:(x)=>setState(()=>pin=x!),
          )
        ]),
        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Delivery charge: ₹30\nPayment: UPI or Cash on Delivery', style: TextStyle(fontSize: 16)))),
        const SizedBox(height: 10),
        ...items.map((i)=>Card(child: ListTile(
          leading: CircleAvatar(child: Icon(i.icon)),
          title: Text(i.name),
          subtitle: Text('₹${i.price}'),
          trailing: FilledButton(onPressed:()=>add(i), child: const Text('ADD')),
        ))),
        const SizedBox(height: 12),
        if(cart.isNotEmpty) ...[
          const Text('Your Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...cart.entries.map((e)=>ListTile(
            title: Text(e.key.name),
            subtitle: Text('₹${e.key.price} × ${e.value}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children:[
              IconButton(onPressed:()=>remove(e.key), icon:const Icon(Icons.remove_circle_outline)),
              Text('${e.value}'),
              IconButton(onPressed:()=>add(e.key), icon:const Icon(Icons.add_circle)),
            ]),
          )),
          const Divider(),
          Text('Subtotal: ₹$subtotal', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Delivery: ₹30'),
          Text('Total: ₹${subtotal+30}', style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          FilledButton(onPressed: () => checkout(context), child: const Text('Place Order')),
        ],
        const SizedBox(height: 24),
        const Text('Customer Support', style: TextStyle(fontWeight: FontWeight.bold)),
        TextButton.icon(onPressed:()=>launchUrl(Uri.parse('tel:7978407812')), icon:const Icon(Icons.phone), label:const Text('7978407812')),
        TextButton.icon(onPressed:()=>launchUrl(Uri.parse('mailto:isatyabhusankar@gmail.com')), icon:const Icon(Icons.email), label:const Text('isatyabhusankar@gmail.com')),
      ],
    ),
  );

  void checkout(BuildContext context) {
    String payment='UPI';
    showModalBottomSheet(context:context, isScrollControlled:true, builder:(ctx)=>StatefulBuilder(builder:(ctx,setModal)=>Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize:MainAxisSize.min, children:[
        const Text('Choose Payment Method', style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
        RadioListTile(value:'UPI',groupValue:payment,onChanged:(v)=>setModal(()=>payment=v!),title:const Text('UPI')),
        RadioListTile(value:'COD',groupValue:payment,onChanged:(v)=>setModal(()=>payment=v!),title:const Text('Cash on Delivery')),
        FilledButton(onPressed:(){
          Navigator.pop(ctx);
          showDialog(context:context,builder:(_)=>AlertDialog(
            title:const Text('Order Placed'),
            content:Text('Your order request is placed using $payment.\nDelivery PIN: $pin\nTotal: ₹${subtotal+30}\nSupport: 7978407812'),
            actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('OK'))],
          ));
        }, child:const Text('Confirm Order'))
      ],
    )));
  }
}
