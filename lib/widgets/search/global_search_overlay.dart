// [global_search_overlay_fixed.dart]
// 📁 Ubicación: /lib/widgets/search/global_search_overlay.dart (REEMPLAZAR COMPLETO)
// 🚀 SEARCH GLOBAL SIN ERRORES DE LAYOUT - VERSIÓN CORREGIDA

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_option.dart';

class GlobalSearchOverlay extends StatefulWidget {
  final Function(String) onNavigate;
  final VoidCallback onClose;

  const GlobalSearchOverlay({
    super.key,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  State<GlobalSearchOverlay> createState() => _GlobalSearchOverlayState();
}

class _GlobalSearchOverlayState extends State<GlobalSearchOverlay>
    with TickerProviderStateMixin {
  // ✅ ANIMATION CONTROLLERS
  late AnimationController _overlayController;
  late AnimationController _searchBarController;
  late AnimationController _resultsController;
  late AnimationController _pulseController;

  // ✅ ANIMATIONS
  late Animation<double> _backdropAnimation;
  late Animation<double> _searchBarScale;
  late Animation<Offset> _searchBarSlide;
  late Animation<double> _resultsOpacity;
  late Animation<double> _pulseAnimation;

  // ✅ SEARCH STATE
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  List<SearchResult> _results = [];
  int _selectedIndex = 0;
  bool _showTypewriter = true;

  // ✅ TYPEWRITER EFFECT
  String _currentPlaceholder = '';
  final List<String> _placeholders = [
    'Buscar clientes...',
    'Buscar eventos...',
    'Buscar profesionales...',
    'Crear nueva cita...',
    'Ver reportes...',
    'Configurar sistema...',
  ];
  int _placeholderIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
    _setupSearchListener();
    _startTypewriterEffect();
  }

  void _initAnimations() {
    // ✅ OVERLAY BACKDROP (300ms)
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _backdropAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    ));

    // ✅ SEARCH BAR ENTRANCE (400ms)
    _searchBarController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _searchBarScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchBarController,
      curve: Curves.elasticOut,
    ));
    _searchBarSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchBarController,
      curve: Curves.easeOutCubic,
    ));

    // ✅ RESULTS STAGGER (600ms)
    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _resultsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultsController,
      curve: Curves.easeOut,
    ));

    // ✅ PULSE EFFECT (1200ms)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  void _startAnimationSequence() async {
    // ✅ SECUENCIA CINEMATOGRÁFICA
    _overlayController.forward(); // Backdrop blur
    await Future.delayed(const Duration(milliseconds: 100));
    _searchBarController.forward(); // Search bar appears
    await Future.delayed(const Duration(milliseconds: 200));
    _searchFocus.requestFocus(); // Auto focus
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      final query = _searchController.text;
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
          _showTypewriter = query.isEmpty;
        });
        _performSearch(query);
      }
    });
  }

  void _startTypewriterEffect() {
    if (_placeholderIndex < _placeholders.length) {
      _typeCurrentPlaceholder();
    }
  }

  void _typeCurrentPlaceholder() async {
    if (!_showTypewriter || !mounted) return;

    final placeholder = _placeholders[_placeholderIndex];

    // ✅ TYPING EFFECT
    for (int i = 0; i <= placeholder.length; i++) {
      if (!_showTypewriter || !mounted) return;

      setState(() {
        _currentPlaceholder = placeholder.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 80));
    }

    // ✅ PAUSE BEFORE NEXT
    await Future.delayed(const Duration(milliseconds: 1500));

    // ✅ ERASING EFFECT
    for (int i = placeholder.length; i >= 0; i--) {
      if (!_showTypewriter || !mounted) return;

      setState(() {
        _currentPlaceholder = placeholder.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 40));
    }

    // ✅ NEXT PLACEHOLDER
    if (mounted) {
      setState(() {
        _placeholderIndex = (_placeholderIndex + 1) % _placeholders.length;
      });
      _typeCurrentPlaceholder();
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = _getQuickActions();
        _selectedIndex = 0;
      });
      _resultsController.reset();
      _resultsController.forward();
      return;
    }

    // ✅ SEARCH LOGIC
    final results = <SearchResult>[];

    // Buscar en sidebar options
    final filteredOptions = sidebarOptions
        .where((option) =>
            option.label.toLowerCase().contains(query.toLowerCase()) ||
            option.group.toLowerCase().contains(query.toLowerCase()))
        .toList();

    for (final option in filteredOptions) {
      results.add(SearchResult(
        title: option.label,
        subtitle: option.group,
        type: SearchResultType.navigation,
        icon: option.icon,
        route: option.route,
        color: kBrandPurple,
      ));
    }

    // ✅ QUICK ACTIONS
    if (query.toLowerCase().contains('crear') ||
        query.toLowerCase().contains('nuevo')) {
      results.addAll(_getCreationActions());
    }

    setState(() {
      _results = results;
      _selectedIndex = 0;
    });

    _resultsController.reset();
    _resultsController.forward();
  }

  List<SearchResult> _getQuickActions() {
    return [
      SearchResult(
        title: 'Crear Nuevo Cliente',
        subtitle: 'Registrar cliente individual',
        type: SearchResultType.action,
        icon: Icons.person_add,
        route: '/clientes/nuevo',
        color: kAccentBlue,
        shortcut: '⌘ + N',
      ),
      SearchResult(
        title: 'Nueva Cita',
        subtitle: 'Programar cita individual',
        type: SearchResultType.action,
        icon: Icons.event_available,
        route: '/agenda/nueva',
        color: kAccentGreen,
        shortcut: '⌘ + E',
      ),
      SearchResult(
        title: 'Evento Corporativo',
        subtitle: 'Crear evento empresarial',
        type: SearchResultType.action,
        icon: Icons.business_center,
        route: '/eventos',
        color: kBrandPurple,
        shortcut: '⌘ + B',
      ),
      SearchResult(
        title: 'Ver KYM Pulse',
        subtitle: 'Dashboard de analytics',
        type: SearchResultType.navigation,
        icon: Icons.analytics,
        route: '/kympulse',
        color: kBrandPurple,
      ),
    ];
  }

  List<SearchResult> _getCreationActions() {
    return [
      SearchResult(
        title: 'Crear Cliente',
        subtitle: 'Nuevo cliente individual',
        type: SearchResultType.action,
        icon: Icons.person_add,
        route: '/clientes/nuevo',
        color: kAccentBlue,
      ),
      SearchResult(
        title: 'Crear Profesional',
        subtitle: 'Registrar nuevo terapeuta',
        type: SearchResultType.action,
        icon: Icons.person_add_alt,
        route: '/profesionales/nuevo',
        color: kAccentGreen,
      ),
    ];
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _closeSearch();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % _results.length;
        });
        HapticFeedback.selectionClick();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex =
              (_selectedIndex - 1 + _results.length) % _results.length;
        });
        HapticFeedback.selectionClick();
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_results.isNotEmpty) {
          _selectResult(_results[_selectedIndex]);
        }
      }
    }
  }

  void _selectResult(SearchResult result) {
    HapticFeedback.lightImpact();
    widget.onNavigate(result.route);
    _closeSearch();
  }

  void _closeSearch() {
    _overlayController.reverse().then((_) {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _searchBarController.dispose();
    _resultsController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ INICIALIZAR RESULTS SI ESTÁN VACÍOS
    if (_results.isEmpty && _searchQuery.isEmpty) {
      _results = _getQuickActions();
    }

    return Material(
      type: MaterialType.transparency,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyPress,
        child: AnimatedBuilder(
          animation: _backdropAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // ✅ BACKDROP FIXED
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeSearch,
                    child: Container(
                      color: Colors.black
                          .withValues(alpha: 0.06 * _backdropAnimation.value),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(
                          sigmaX: 10 * _backdropAnimation.value,
                          sigmaY: 10 * _backdropAnimation.value,
                        ),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),

                // ✅ SEARCH CONTAINER CENTERED
                Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent close on search container tap
                    child: _buildSearchContainer(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchContainer() {
    return AnimatedBuilder(
      animation: Listenable.merge([_searchBarController, _resultsController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _searchBarScale.value,
          child: SlideTransition(
            position: _searchBarSlide,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 580,
                maxHeight: 600,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: kBrandPurple.withValues(alpha: 0.02),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kBrandPurple.withValues(alpha: 0.03),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 60,
                      offset: const Offset(0, 30),
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSearchHeader(),
                    _buildSearchInput(),
                    if (_results.isNotEmpty) _buildResults(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.008),
            kAccentBlue.withValues(alpha: 0.004),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kBrandPurple, kAccentBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kBrandPurple.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Búsqueda Global',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kBrandPurple,
                  ),
                ),
                Text(
                  'Encuentra cualquier cosa en tu CRM',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'ESC',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText:
              _showTypewriter ? _currentPlaceholder : 'Escribe para buscar...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kBrandPurple.withValues(alpha: 0.01),
                  kAccentBlue.withValues(alpha: 0.005),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.search,
              color: kBrandPurple.withValues(alpha: 0.07),
              size: 20,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _searchFocus.requestFocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kBorderColor.withValues(alpha: 0.03)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBrandPurple, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kBorderColor.withValues(alpha: 0.03)),
          ),
          filled: true,
          fillColor: kBrandPurpleLight.withValues(alpha: 0.005),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return AnimatedBuilder(
      animation: _resultsOpacity,
      builder: (context, child) {
        return Opacity(
          opacity: _resultsOpacity.value,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final delay = index * 0.05;
                final staggerValue = Curves.easeOut.transform(
                    ((_resultsOpacity.value - delay).clamp(0.0, 1.0) /
                            (1.0 - delay))
                        .clamp(0.0, 1.0));

                return Transform.translate(
                  offset: Offset(0, 20 * (1 - staggerValue)),
                  child: Opacity(
                    opacity: staggerValue,
                    child: _buildResultItem(_results[index], index),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultItem(SearchResult result, int index) {
    final isSelected = index == _selectedIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectResult(result),
          onHover: (hovered) {
            if (hovered) {
              setState(() => _selectedIndex = index);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? result.color.withValues(alpha: 0.008)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? result.color.withValues(alpha: 0.03)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // ✅ ICON CON ANIMACIÓN
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              result.color,
                              result.color.withValues(alpha: 0.08)
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade200,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: result.color.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Transform.scale(
                    scale: isSelected ? 1.1 : 1.0,
                    child: Icon(
                      result.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // ✅ CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? result.color : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ SHORTCUT O TYPE BADGE
                if (result.shortcut != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? result.color.withValues(alpha: 0.01)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? result.color.withValues(alpha: 0.03)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      result.shortcut!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? result.color : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(
                    result.type == SearchResultType.action
                        ? Icons.flash_on
                        : Icons.arrow_forward_ios,
                    size: 14,
                    color: isSelected ? result.color : Colors.grey.shade400,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ SEARCH RESULT MODEL
class SearchResult {
  final String title;
  final String subtitle;
  final SearchResultType type;
  final IconData icon;
  final String route;
  final Color color;
  final String? shortcut;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.route,
    required this.color,
    this.shortcut,
  });
}

enum SearchResultType {
  navigation,
  action,
  data,
}
