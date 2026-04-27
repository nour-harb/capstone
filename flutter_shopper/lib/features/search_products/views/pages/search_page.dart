import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';
import 'package:flutter_shopper/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter_shopper/features/search_products/views/pages/search_results_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value, String gender) {
    if (value.trim().isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SearchResultsPage(queryText: value.trim(), gender: gender),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeNotifier = ref.read(homeViewmodelProvider.notifier);
    final selectedGender = ref.watch(
      homeViewmodelProvider.select((s) => homeNotifier.selectedGender),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildGenderToggle(homeNotifier, selectedGender),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) =>
                    _onSearchSubmitted(value, selectedGender),
                decoration: InputDecoration(
                  hintText: 'SEARCH FOR ITEMS...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Pallete.blackColor,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    color: Pallete.blackColor,
                    onPressed: () => _onSearchSubmitted(
                      _searchController.text,
                      selectedGender,
                    ),
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Pallete.greyColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Pallete.blackColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderToggle(HomeViewmodel homeNotifier, String selectedGender) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['MAN', 'WOMAN'].map((gender) {
          final isSelected = selectedGender == gender.toLowerCase();
          return GestureDetector(
            onTap: () => homeNotifier.selectGender(gender.toLowerCase()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                gender,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w400,
                  color: isSelected ? Pallete.blackColor : Pallete.greyColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
