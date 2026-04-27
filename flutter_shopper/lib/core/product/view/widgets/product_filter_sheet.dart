import 'package:flutter/material.dart';
import 'package:flutter_shopper/core/product/models/base_product_query.dart';
import 'package:flutter_shopper/core/product/models/base_product_state.dart';
import 'package:flutter_shopper/core/product/viewmodel/product_filter_mixin.dart';
import 'package:flutter_shopper/core/theme/app_pallete.dart';

class ProductFilterSheet<
  T extends BaseProductQuery,
  S extends BaseProductState<T>
>
    extends StatefulWidget {
  final ProductFilterMixin<T, S> viewModel;
  final S state;

  const ProductFilterSheet({
    super.key,
    required this.viewModel,
    required this.state,
  });

  @override
  State<ProductFilterSheet<T, S>> createState() =>
      _ProductFilterSheetState<T, S>();
}

class _ProductFilterSheetState<
  T extends BaseProductQuery,
  S extends BaseProductState<T>
>
    extends State<ProductFilterSheet<T, S>> {
  late ValueNotifier<T> _uiFilter;
  final Set<String> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _uiFilter = ValueNotifier<T>(widget.state.currentFilter);
  }

  @override
  void dispose() {
    _uiFilter.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.viewModel.loadProducts(_uiFilter.value, reset: true);
    Navigator.pop(context);
  }

  Widget _buildFilterSection<V>({
    required String title,
    required List<dynamic> options,
    required List<V> selectedValues,
    required Function(V) onToggle,
    required String valueKey,
    required String labelKey,
    bool showClearButton = false,
    VoidCallback? onClear,
    int limit = 5,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final isExpanded = _expandedSections.contains(title);
    final hasOverflow = options.length > limit;
    final displayedOptions = (hasOverflow && !isExpanded)
        ? options.take(limit).toList()
        : options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (showClearButton && selectedValues.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Text(
                  'Clear',
                  style: textTheme.labelSmall?.copyWith(
                    color: Pallete.errorColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: displayedOptions.map((option) {
            final value = (option is Map)
                ? option[valueKey] as V
                : option.id as V;
            final label = (option is Map)
                ? option[labelKey] as String
                : option.name as String;
            return ChoiceChip(
              label: Text(label),
              selected: selectedValues.contains(value),
              onSelected: (_) => onToggle(value),
              // Fixing the purple tint:
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: selectedValues.contains(value)
                    ? Colors.white
                    : Colors.black,
                fontSize: 13,
              ),
            );
          }).toList(),
        ),
        if (hasOverflow)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: Colors.black,
              ),
              onPressed: () => setState(
                () => isExpanded
                    ? _expandedSections.remove(title)
                    : _expandedSections.add(title),
              ),
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 18,
              ),
              label: Text(
                isExpanded ? 'Show Less' : 'Show More',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomSheetTheme = Theme.of(context).bottomSheetTheme;
    final sheetHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: bottomSheetTheme.backgroundColor,
        borderRadius: bottomSheetTheme.shape is RoundedRectangleBorder
            ? (bottomSheetTheme.shape as RoundedRectangleBorder).borderRadius
            : null,
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildHeader(context, textTheme),
          const Divider(),
          Expanded(
            child: ValueListenableBuilder<T>(
              valueListenable: _uiFilter,
              builder: (context, filter, _) {
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  children: [
                    _buildFilterSection<String>(
                      title: 'SORT BY',
                      options: const [
                        {'value': 'newest', 'label': 'Newest'},
                        {'value': 'price_asc', 'label': 'Price: Low to High'},
                        {'value': 'price_desc', 'label': 'Price: High to Low'},
                      ],
                      selectedValues: [filter.sortBy],
                      onToggle: (val) => _uiFilter.value =
                          filter.copyWith(sortBy: val, page: 1) as T,
                      valueKey: 'value',
                      labelKey: 'label',
                    ),
                    const SizedBox(height: 32),
                    _buildFilterSection<int>(
                      title: 'BRAND',
                      options: widget.state.availableBrands,
                      selectedValues: filter.brandIds,
                      onToggle: (id) {
                        final next = List<int>.from(filter.brandIds);
                        next.contains(id) ? next.remove(id) : next.add(id);
                        _uiFilter.value =
                            filter.copyWith(brandIds: next, page: 1) as T;
                      },
                      valueKey: 'id',
                      labelKey: 'name',
                      showClearButton: true,
                      onClear: () => _uiFilter.value =
                          filter.copyWith(brandIds: [], page: 1) as T,
                    ),
                    const SizedBox(height: 32),
                    _buildFilterSection<int>(
                      title: 'SIZE',
                      options: widget.state.availableSizes,
                      selectedValues: filter.sizeIds,
                      onToggle: (id) {
                        final next = List<int>.from(filter.sizeIds);
                        next.contains(id) ? next.remove(id) : next.add(id);
                        _uiFilter.value =
                            filter.copyWith(sizeIds: next, page: 1) as T;
                      },
                      valueKey: 'id',
                      labelKey: 'name',
                      showClearButton: true,
                      onClear: () => _uiFilter.value =
                          filter.copyWith(sizeIds: [], page: 1) as T,
                    ),
                    const SizedBox(height: 32),
                    _buildFilterSection<int>(
                      title: 'COLOR',
                      options: widget.state.availableColors,
                      selectedValues: filter.colorIds,
                      onToggle: (id) {
                        final next = List<int>.from(filter.colorIds);
                        next.contains(id) ? next.remove(id) : next.add(id);
                        _uiFilter.value =
                            filter.copyWith(colorIds: next, page: 1) as T;
                      },
                      valueKey: 'id',
                      labelKey: 'name',
                      showClearButton: true,
                      onClear: () => _uiFilter.value =
                          filter.copyWith(colorIds: [], page: 1) as T,
                    ),
                  ],
                );
              },
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SORT & FILTER',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              ValueListenableBuilder<T>(
                valueListenable: _uiFilter,
                builder: (context, filter, _) {
                  final hasActive =
                      filter.brandIds.isNotEmpty ||
                      filter.sizeIds.isNotEmpty ||
                      filter.colorIds.isNotEmpty ||
                      filter.sortBy != 'newest';
                  if (!hasActive) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: () => _uiFilter.value =
                        _uiFilter.value.copyWith(
                              brandIds: [],
                              sizeIds: [],
                              colorIds: [],
                              sortBy: 'newest',
                              page: 1,
                            )
                            as T,
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        onPressed: _applyFilters,
        child: const Text('APPLY CHANGES'),
      ),
    );
  }
}
