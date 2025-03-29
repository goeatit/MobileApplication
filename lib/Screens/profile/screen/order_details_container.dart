import 'package:flutter/material.dart';
import 'package:eatit/models/order_model.dart';

class OrderDetailsContainer extends StatefulWidget {
  final Order order;

  const OrderDetailsContainer({super.key, required this.order});

  @override
  _OrderDetailsContainerState createState() => _OrderDetailsContainerState();
}

class _OrderDetailsContainerState extends State<OrderDetailsContainer> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Text('Order ID: ${widget.order.id}'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  // Copy order ID to clipboard
                },
              ),
            ],
          ),
          Row(
            children: [
              Text('Restaurant: ${widget.order.restaurantName}'),
              const Spacer(),
              Text('Time: ${widget.order.time}'),
            ],
          ),
          ExpansionTile(
            title: const Text('Items'),
            trailing:
                Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onExpansionChanged: (value) {
              setState(() {
                isExpanded = value;
              });
            },
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.order.items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.order.items[index].name),
                    subtitle:
                        Text('Quantity: ${widget.order.items[index].quantity}'),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Cancel order
                },
                child: const Text('Cancel Order'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // See direction
                },
                child: const Text('See Direction'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
