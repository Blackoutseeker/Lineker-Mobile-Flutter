import 'package:flutter/material.dart';

import '../../../models/routes/app_routes.dart';

class FilterButtonWidget extends StatelessWidget {
  const FilterButtonWidget({Key? key}) : super(key: key);

  void _navigateToFiltersScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.filters);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FittedBox(
        child: TextButton(
          onPressed: () => _navigateToFiltersScreen(context),
          child: Row(
            children: const <Widget>[
              Text(
                'Filters',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.filter_alt,
                color: Color(0xFFFFFFFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
