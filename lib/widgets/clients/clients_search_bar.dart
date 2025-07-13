// [clients_search_bar.dart] - CÓDIGO COMPLETO CON BORDES REDONDEADOS
// 📁 Ubicación: /lib/widgets/clients/clients_search_bar.dart
// 🎯 OBJETIVO: Search bar con constraint 800px para consistencia y bordes redondeados

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 🔍 SEARCH BAR CON CONSTRAINT 800PX Y BORDES REDONDEADOS
class ClientsSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onClear;
  final String hintText;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final List<String>? suggestions;
  final bool enabled;

  const ClientsSearchBar({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onClear,
    this.hintText = 'Buscar clientes...',
    this.onSubmitted,
    this.onChanged,
    this.suggestions,
    this.enabled = true,
  });

  @override
  State<ClientsSearchBar> createState() => _ClientsSearchBarState();
}

class _ClientsSearchBarState extends State<ClientsSearchBar>
    with SingleTickerProviderStateMixin {
  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;

  // ✅ ESTADO DE UI
  bool _isFocused = false;
  bool _showSuggestions = false;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // ✅ SUGERENCIAS FILTRADAS
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeListeners();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: ClientConstants.MICRO_ANIMATION_DURATION,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _borderColorAnimation = ColorTween(
      begin: kBorderSoft,
      end: kBrandPurple,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _initializeListeners() {
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
      _showSuggestionsIfNeeded();
    } else {
      _animationController.reverse();
      _hideSuggestions();
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text;

    // Notificar cambio si hay callback
    if (widget.onChanged != null) {
      widget.onChanged!(text);
    }

    // Actualizar sugerencias
    _updateSuggestions(text);
  }

  void _updateSuggestions(String query) {
    if (widget.suggestions == null ||
        query.length < ClientConstants.MIN_SEARCH_CHARS) {
      _hideSuggestions();
      return;
    }

    final filtered = widget.suggestions!
        .where((suggestion) =>
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .take(8) // Limitar a 8 sugerencias
        .toList();

    setState(() {
      _filteredSuggestions = filtered;
    });

    if (filtered.isNotEmpty && _isFocused) {
      _showSuggestionsOverlay();
    } else {
      _hideSuggestions();
    }
  }

  void _showSuggestionsIfNeeded() {
    if (widget.controller.text.length >= ClientConstants.MIN_SEARCH_CHARS) {
      _updateSuggestions(widget.controller.text);
    }
  }

  void _showSuggestionsOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = _createSuggestionsOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _showSuggestions = true;
    });
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _showSuggestions = false;
    });
  }

  OverlayEntry _createSuggestionsOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: _getSearchBarWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // Altura del search bar + padding
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(20), // ✅ CAMBIO: Más redondeado
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 300,
                maxWidth: 800, // ✅ 800PX CONSTRAINT APLICADO
              ),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(20), // ✅ CAMBIO: Más redondeado
                border: Border.all(color: kBorderSoft),
              ),
              child: _buildSuggestionsList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      itemCount: _filteredSuggestions.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: kBorderSoft,
      ),
      itemBuilder: (context, index) {
        final suggestion = _filteredSuggestions[index];
        return _buildSuggestionItem(suggestion);
      },
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return InkWell(
      onTap: () => _selectSuggestion(suggestion),
      borderRadius: BorderRadius.circular(12), // ✅ CAMBIO: Bordes redondeados
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 18,
              color: kTextMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.north_west,
              size: 16,
              color: kTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  double _getSearchBarWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final screenWidth = renderBox?.size.width ?? 800;
    // ✅ MÁXIMO 800PX - MÍNIMO 300PX
    return screenWidth.clamp(300.0, 800.0);
  }

  void _selectSuggestion(String suggestion) {
    widget.controller.text = suggestion;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );

    _hideSuggestions();
    _focusNode.unfocus();

    if (widget.onSubmitted != null) {
      widget.onSubmitted!(suggestion);
    }

    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    _hideSuggestions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800), // ✅ 800PX CONSTRAINT
        child: CompositedTransformTarget(
          link: _layerLink,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        20), // ✅ CAMBIO: Más redondeado (era 12)
                    border: Border.all(
                      color: _borderColorAnimation.value ?? kBorderSoft,
                      width: _isFocused ? 2 : 1,
                    ),
                    boxShadow: _isFocused ? kSombraCardElevated : kSombraCard,
                  ),
                  child: _buildSearchField(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ✅ ACTUALIZADO: Campo de búsqueda con bordes más redondeados y mejor padding
  Widget _buildSearchField() {
    return ClipRRect(
      // ✅ AGREGADO: ClipRRect para redondear el fondo interno
      borderRadius: BorderRadius.circular(20), // ✅ MISMO RADIO QUE EL CONTAINER
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onFieldSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: kTextMuted,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: _buildPrefixIcon(),
          suffixIcon: _buildSuffixIcon(),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true, // ✅ AGREGADO: Asegurar que esté filled
          fillColor: Colors.white, // ✅ AGREGADO: Color de fondo explícito
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPrefixIcon() {
    return AnimatedSwitcher(
      duration: ClientConstants.MICRO_ANIMATION_DURATION,
      child: widget.isSearching
          ? Padding(
              key: const ValueKey('searching'),
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
                ),
              ),
            )
          : Icon(
              key: const ValueKey('search'),
              Icons.search,
              color: _isFocused ? kBrandPurple : kTextMuted,
              size: 24,
            ),
    );
  }

  Widget _buildSuffixIcon() {
    if (widget.controller.text.isEmpty) {
      return _buildMicrophoneButton();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showSuggestions)
          IconButton(
            onPressed: _hideSuggestions,
            icon: Icon(
              Icons.keyboard_arrow_up,
              color: kTextMuted,
            ),
            tooltip: 'Ocultar sugerencias',
          ),
        IconButton(
          onPressed: _clearSearch,
          icon: Icon(
            Icons.close,
            color: kTextMuted,
          ),
          tooltip: 'Limpiar búsqueda',
        ),
      ],
    );
  }

  Widget _buildMicrophoneButton() {
    return IconButton(
      onPressed: _startVoiceSearch,
      icon: Icon(
        Icons.mic_outlined,
        color: kTextMuted,
      ),
      tooltip: 'Búsqueda por voz',
    );
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onClear();
    _hideSuggestions();
    HapticFeedback.lightImpact();
  }

  void _startVoiceSearch() {
    // TODO: Implementar búsqueda por voz
    debugPrint('🎤 Iniciando búsqueda por voz');
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Búsqueda por voz - Función en desarrollo'),
        backgroundColor: kBrandPurple,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              12), // ✅ CAMBIO: Bordes redondeados en snackbar
        ),
      ),
    );
  }
}
