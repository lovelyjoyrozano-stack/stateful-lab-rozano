import 'package:flutter/material.dart';

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CartScreen(),
      ),
    );

/// Model class para sa item sa shopping cart.
class CartItem {
  final String name;
  final double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

/// Main StatefulWidget screen alang sa shopping cart.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // List sa mga cart items nga naa sa state
  final List<CartItem> _items = [];

  // Controllers para sa text inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Variables para sa error messages sa validation
  String? _nameError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    // Pag-preload ug 3 ka bag-ong sample items (lahi nga items)
    _items.addAll([
      CartItem(name: 'Bread', price: 45.00, quantity: 1),
      CartItem(name: 'Coffee', price: 120.00, quantity: 2),
      CartItem(name: 'Sugar', price: 55.00, quantity: 1),
    ]);
  }

  @override
  void dispose() {
    // Pag-dispose sa mga controllers aron malikayan ang memory leaks
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Pagkwenta sa total price base sa price * quantity sa tanang items
  double get _total {
    double sum = 0.0;
    for (var item in _items) {
      sum += item.price * item.quantity;
    }
    return sum;
  }

  /// Pag-ihap sa pilang kabuok items ang marked as "got it"
  int get _gotItCount {
    return _items.where((item) => item.gotIt).length;
  }

  // Mga state modification functions gamit ang setState()
  void _increase(int index) {
    setState(() {
      if (_items[index].quantity < 99) {
        _items[index].quantity++;
      }
    });
  }

  void _decrease(int index) {
    setState(() {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      }
    });
  }

  void _toggle(int index, bool? value) {
    setState(() {
      _items[index].gotIt = value ?? false;
    });
  }

  void _addItem() {
    final String name = _nameController.text.trim();
    final double? price = double.tryParse(_priceController.text.trim());

    setState(() {
      // Input Validation
      _nameError = name.isEmpty ? 'Enter name' : null;

      if (_priceController.text.trim().isEmpty) {
        _priceError = 'Enter price';
      } else if (price == null || price <= 0) {
        _priceError = 'Must be > 0';
      } else {
        _priceError = null;
      }

      // Kung valid ang input, i-add ang item ug i-clear ang input fields
      if (_nameError == null && _priceError == null && price != null) {
        _items.add(CartItem(name: name, price: price));
        _nameController.clear();
        _priceController.clear();
        FocusScope.of(context).unfocus(); // I-hide ang keyboard
      }
    });
  }

  void _clearChecked() {
    setState(() {
      _items.removeWhere((item) => item.gotIt);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Shopping Cart'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // ListView nga gi-wrap sa Expanded para malikayan ang unbounded height error
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return CartItemTile(
                      item: item,
                      onIncrease: () => _increase(index),
                      onDecrease: () => _decrease(index),
                      onToggle: (val) => _toggle(index, val),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Summary bar para sa total count, checked count, ug live total
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items: ${_items.length}  •  Got it: $_gotItCount',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Total: PHP ${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Form fields para sa pagdugang ug item
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Item name',
                        errorText: _nameError,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        errorText: _priceError,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearChecked,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Clear checked',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
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

/// Stateless child widget para sa matag row sa cart item.
/// Dili kini mag-call ug setState sa iyang kaugalingon; mogamit kini og callbacks.
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<bool?> onToggle;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            // Checkbox para sa 'got it' status
            Checkbox(
              value: item.gotIt,
              onChanged: onToggle,
            ),

            // Pangalan sa item ug presyo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: item.gotIt
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.gotIt ? Colors.grey : Colors.black,
                    ),
                  ),
                  Text(
                    'PHP ${item.price.toStringAsFixed(2)} each',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Mga buton sa Quantity (+ ug -)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: item.quantity > 1 ? onDecrease : null,
              color: Colors.teal,
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: item.quantity < 99 ? onIncrease : null,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}