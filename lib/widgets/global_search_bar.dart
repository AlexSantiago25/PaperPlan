import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import 'doodle_painters.dart';

class GlobalSearchBar extends StatefulWidget {
  final bool autofocus;
  final VoidCallback? onSearchSubmitted;

  const GlobalSearchBar({
    super.key,
    this.autofocus = false,
    this.onSearchSubmitted,
  });

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    _controller = TextEditingController(text: provider.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.penBlueDark.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: DoodleBorderPainter(
          color: provider.searchQuery.isNotEmpty ? AppTheme.penRed : AppTheme.penBlue,
          strokeWidth: 1.8,
          borderRadius: 12.0,
          isDoubleLine: provider.searchQuery.isNotEmpty,
        ),
        child: TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          style: GoogleFonts.patrickHand(
            color: AppTheme.penBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar objetos o pertenencias (ej. "cable USB", "pasaporte")...',
            hintStyle: GoogleFonts.patrickHand(
              color: AppTheme.penBlack.withValues(alpha: 0.4),
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppTheme.penBlue,
              size: 22,
            ),
            suffixIcon: provider.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppTheme.penRed,
                    onPressed: () {
                      _controller.clear();
                      provider.clearSearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            provider.setSearchQuery(value);
          },
          onSubmitted: (_) {
            widget.onSearchSubmitted?.call();
          },
        ),
      ),
    );
  }
}
