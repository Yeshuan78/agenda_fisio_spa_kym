// [widget_laboratory_screen.dart] - LABORATORIO DE WIDGETS (SIN DEPENDENCIAS)
// 📁 Ubicación: /lib/screens/dev_tools/widget_laboratory_screen.dart
// 🎯 OBJETIVO: Testing y showcase de widgets - VERSIÓN INDEPENDIENTE

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

/// 🧪 LABORATORIO DE WIDGETS ENTERPRISE (SIN DEPENDENCIAS EXTERNAS)
/// Permite testing, showcase y validación de cualquier widget en desarrollo
class WidgetLaboratoryScreen extends StatefulWidget {
  const WidgetLaboratoryScreen({super.key});

  @override
  State<WidgetLaboratoryScreen> createState() => _WidgetLaboratoryScreenState();
}

class _WidgetLaboratoryScreenState extends State<WidgetLaboratoryScreen>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES Y ESTADO
  late TabController _tabController;
  String _selectedCategory = 'Basic Widgets';
  bool _isDarkMode = false;
  double _scaleFactor = 1.0;
  String _backgroundType = 'default';

  // ✅ CATEGORÍAS DE WIDGETS
  final List<String> _categories = [
    'Basic Widgets',
    'Theme Demo',
    'Forms',
    'Cards',
    'Buttons',
    'Navigation',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildControlPanel(),
            Expanded(child: _buildLabContent()),
          ],
        ),
      ),
      floatingActionButton: _buildQuickActions(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: kHeaderGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: kSombraHeader,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.science, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Widget Laboratory',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Testing & Showcase Platform',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        IconButton(
          onPressed: () => _toggleTheme(),
          icon: Icon(
            _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          tooltip: 'Toggle Theme',
        ),
        IconButton(
          onPressed: () => _resetView(),
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Reset View',
        ),
        IconButton(
          onPressed: () => _showSettings(),
          icon: const Icon(Icons.settings, color: Colors.white),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCategorySelector(),
          const SizedBox(height: 12),
          _buildViewControls(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: kBrandPurple,
        indicatorWeight: 3,
        labelColor: kBrandPurple,
        unselectedLabelColor: kTextSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        onTap: (index) {
          setState(() {
            _selectedCategory = _categories[index];
          });
          HapticFeedback.lightImpact();
        },
        tabs: _categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }

  Widget _buildViewControls() {
    return Row(
      children: [
        Expanded(child: _buildScaleControl()),
        const SizedBox(width: 12),
        Expanded(child: _buildBackgroundControl()),
        const SizedBox(width: 12),
        _buildQuickInfoButton(),
      ],
    );
  }

  Widget _buildScaleControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSoft),
      ),
      child: Row(
        children: [
          const Icon(Icons.zoom_in, size: 18, color: kTextSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: _scaleFactor,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              activeColor: kBrandPurple,
              onChanged: (value) {
                setState(() {
                  _scaleFactor = value;
                });
              },
            ),
          ),
          Text(
            '${(_scaleFactor * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundControl() {
    final backgrounds = ['default', 'dark', 'gradient', 'pattern'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSoft),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _backgroundType,
          isDense: true,
          icon: const Icon(Icons.palette, size: 18, color: kTextSecondary),
          items: backgrounds
              .map((bg) => DropdownMenuItem(
                    value: bg,
                    child: Text(
                      bg.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _backgroundType = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildQuickInfoButton() {
    return Container(
      decoration: BoxDecoration(
        color: kBrandPurple,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: _showQuickInfo,
        icon: const Icon(Icons.info_outline, color: Colors.white),
        tooltip: 'Widget Info',
      ),
    );
  }

  Widget _buildLabContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _getContentBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildContentHeader(),
            Expanded(
              child: Transform.scale(
                scale: _scaleFactor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildWidgetShowcase(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBrandPurple.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: kBorderSoft)),
      ),
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(_selectedCategory),
            color: kBrandPurple,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            _selectedCategory,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kBrandPurple,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kAccentGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_getWidgetCount(_selectedCategory)} widgets',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetShowcase() {
    switch (_selectedCategory) {
      case 'Basic Widgets':
        return _buildBasicWidgetsShowcase();
      case 'Theme Demo':
        return _buildThemeShowcase();
      case 'Forms':
        return _buildFormsShowcase();
      case 'Cards':
        return _buildCardsShowcase();
      case 'Buttons':
        return _buildButtonsShowcase();
      case 'Navigation':
        return _buildNavigationShowcase();
      case 'Custom':
        return _buildCustomShowcase();
      default:
        return _buildPlaceholderShowcase();
    }
  }

  // ====================================================================
  // 🧪 SHOWCASES POR CATEGORÍA
  // ====================================================================

  Widget _buildBasicWidgetsShowcase() {
    return Column(
      children: [
        _buildShowcaseSection(
          'Text Widgets',
          [
            const Text(
              'Título Principal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Subtítulo secundario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Text(
              'Texto normal con información descriptiva.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Texto con color personalizado',
              style: TextStyle(fontSize: 16, color: kBrandPurple),
            ),
          ],
        ),
        _buildShowcaseSection(
          'Icons',
          [
            Wrap(
              spacing: 16,
              children: [
                Icon(Icons.star, color: kBrandPurple, size: 32),
                Icon(Icons.favorite, color: Colors.red, size: 32),
                Icon(Icons.thumb_up, color: kAccentGreen, size: 32),
                Icon(Icons.notifications, color: kAccentBlue, size: 32),
              ],
            ),
          ],
        ),
        _buildShowcaseSection(
          'Progress Indicators',
          [
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                LinearProgressIndicator(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeShowcase() {
    return Column(
      children: [
        _buildShowcaseSection(
          'Colores de Marca',
          [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildColorSample('Brand Purple', kBrandPurple),
                _buildColorSample('Accent Blue', kAccentBlue),
                _buildColorSample('Accent Green', kAccentGreen),
                _buildColorSample('Background', kBackgroundColor),
                _buildColorSample('White', kWhite),
              ],
            ),
          ],
        ),
        _buildShowcaseSection(
          'Tipografía',
          [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heading 1',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Heading 2',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Heading 3',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Body Large',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
                Text(
                  'Body Medium',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Text(
                  'Caption',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormsShowcase() {
    return Column(
      children: [
        _buildShowcaseSection(
          'Text Fields',
          [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                hintText: 'Ingresa tu nombre',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'ejemplo@email.com',
                prefixIcon: Icon(Icons.email),
                suffixIcon: Icon(Icons.check_circle, color: kAccentGreen),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText: '••••••••',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.visibility_off),
              ),
              obscureText: true,
            ),
          ],
        ),
        _buildShowcaseSection(
          'Dropdowns y Switches',
          [
            Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Selecciona una opción',
                    prefixIcon: Icon(Icons.list),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'opcion1', child: Text('Opción 1')),
                    DropdownMenuItem(value: 'opcion2', child: Text('Opción 2')),
                    DropdownMenuItem(value: 'opcion3', child: Text('Opción 3')),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Activar notificaciones'),
                    const Spacer(),
                    Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: kBrandPurple,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardsShowcase() {
    return Column(
      children: [
        _buildShowcaseSection(
          'Standard Cards',
          [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_circle, size: 40),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Juan Pérez',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Cliente Premium',
                              style: TextStyle(color: kTextSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                        'Esta es una tarjeta de ejemplo con información del cliente.'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {}, child: const Text('EDITAR')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: () {}, child: const Text('VER DETALLE')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: kBrandPurple.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: kAccentGreen, size: 32),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ventas del Mes',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '+15% vs mes anterior',
                                style: TextStyle(color: kAccentGreen),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '\$25,430',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonsShowcase() {
    return Column(
      children: [
        _buildShowcaseSection(
          'Button Types',
          [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showSnackBar('ElevatedButton pressed'),
                    child: const Text('Elevated Button'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showSnackBar('OutlinedButton pressed'),
                    child: const Text('Outlined Button'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _showSnackBar('TextButton pressed'),
                    child: const Text('Text Button'),
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildShowcaseSection(
          'Icon Buttons',
          [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
        _buildShowcaseSection(
          'Floating Action Buttons',
          [
            Wrap(
              spacing: 16,
              children: [
                FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: kBrandPurple,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                FloatingActionButton.extended(
                  onPressed: () {},
                  backgroundColor: kAccentGreen,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationShowcase() {
    return Column(
      children: [
        _buildShowcaseSection(
          'Navigation Elements',
          [
            const Card(
              child: ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                subtitle: Text('Página principal'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.people),
                title: Text('Clientes'),
                subtitle: Text('Gestión de clientes'),
                trailing: Badge(
                  label: Text('5'),
                  child: Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                subtitle: Text('Ajustes del sistema'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomShowcase() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kAccentGreen.withValues(alpha: 0.1),
                kAccentBlue.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorderSoft),
          ),
          child: const Column(
            children: [
              Icon(Icons.code, size: 48, color: kBrandPurple),
              SizedBox(height: 16),
              Text(
                '🧪 Área de Testing Personalizado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Aquí puedes agregar cualquier widget personalizado para testing.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Instrucciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Agrega tu widget en _buildCustomShowcase()'),
              Text('2. Guarda y usa hot reload'),
              Text('3. Ajusta escala y fondo según necesites'),
              Text('4. Valida comportamiento y styling'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '👇 Agrega tus widgets aquí 👇',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        // 🧪 ÁREA PARA TUS WIDGETS PERSONALIZADOS
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: kBrandPurple, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Espacio para tus widgets de prueba',
              style: TextStyle(color: kTextSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderShowcase() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: kTextMuted),
          SizedBox(height: 16),
          Text(
            'Showcase en construcción',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('Esta categoría será implementada próximamente'),
        ],
      ),
    );
  }

  Widget _buildShowcaseSection(String title, List<Widget> widgets) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBrandPurple.withValues(alpha: 0.2)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kBrandPurple,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...widgets.map((widget) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: widget,
              )),
        ],
      ),
    );
  }

  Widget _buildColorSample(String name, Color color) {
    return Container(
      width: 120,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: const TextStyle(fontSize: 10, color: kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'screenshot',
          onPressed: _takeScreenshot,
          backgroundColor: kAccentBlue,
          child: const Icon(Icons.screenshot, color: Colors.white),
          tooltip: 'Take Screenshot',
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'add_widget',
          onPressed: _addCustomWidget,
          backgroundColor: kBrandPurple,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Widget',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ====================================================================
  // 🎯 MÉTODOS HELPER
  // ====================================================================

  Color _getBackgroundColor() {
    switch (_backgroundType) {
      case 'dark':
        return Colors.grey.shade900;
      case 'gradient':
        return kBackgroundColor;
      case 'pattern':
        return Colors.grey.shade100;
      default:
        return kBackgroundColor;
    }
  }

  Color _getContentBackgroundColor() {
    switch (_backgroundType) {
      case 'dark':
        return Colors.grey.shade800;
      case 'gradient':
        return Colors.white.withValues(alpha: 0.9);
      default:
        return Colors.white;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Basic Widgets':
        return Icons.widgets;
      case 'Theme Demo':
        return Icons.palette;
      case 'Forms':
        return Icons.edit_note;
      case 'Cards':
        return Icons.view_agenda;
      case 'Buttons':
        return Icons.smart_button;
      case 'Navigation':
        return Icons.navigation;
      case 'Custom':
        return Icons.extension;
      default:
        return Icons.widgets;
    }
  }

  int _getWidgetCount(String category) {
    switch (category) {
      case 'Basic Widgets':
        return 6;
      case 'Theme Demo':
        return 8;
      case 'Forms':
        return 5;
      case 'Cards':
        return 2;
      case 'Buttons':
        return 6;
      case 'Navigation':
        return 3;
      case 'Custom':
        return 1;
      default:
        return 0;
    }
  }

  // ====================================================================
  // 🎯 MÉTODOS DE ACCIÓN
  // ====================================================================

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    HapticFeedback.lightImpact();
  }

  void _resetView() {
    setState(() {
      _scaleFactor = 1.0;
      _backgroundType = 'default';
      _isDarkMode = false;
    });
    HapticFeedback.mediumImpact();
    _showSnackBar('Vista restablecida');
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: kBrandPurple),
            SizedBox(width: 12),
            Text('Configuraciones'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 Funcionalidades disponibles:'),
            SizedBox(height: 8),
            Text('• Cambio de escala (50% - 200%)'),
            Text('• Diferentes fondos de prueba'),
            Text('• Toggle dark/light mode'),
            Text('• Testing de widgets personalizados'),
            SizedBox(height: 16),
            Text('💡 Para agregar tus widgets:'),
            Text('1. Ve a la pestaña "Custom"'),
            Text('2. Modifica _buildCustomShowcase()'),
            Text('3. Agrega tu widget y hot reload'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showQuickInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getCategoryIcon(_selectedCategory), color: kBrandPurple),
            const SizedBox(width: 12),
            Text(_selectedCategory),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.widgets, size: 16, color: kTextSecondary),
                const SizedBox(width: 8),
                Text('Widgets: ${_getWidgetCount(_selectedCategory)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.zoom_in, size: 16, color: kTextSecondary),
                const SizedBox(width: 8),
                Text('Escala: ${(_scaleFactor * 100).toInt()}%'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.palette, size: 16, color: kTextSecondary),
                const SizedBox(width: 8),
                Text('Fondo: $_backgroundType'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 16,
                  color: kTextSecondary,
                ),
                const SizedBox(width: 8),
                Text('Tema: ${_isDarkMode ? 'Oscuro' : 'Claro'}'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAccentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kAccentGreen.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tips_and_updates, color: kAccentGreen, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Usa la pestaña "Custom" para testing de tus widgets',
                      style: TextStyle(fontSize: 12, color: kAccentGreen),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _addCustomWidget() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_box, color: kBrandPurple),
            SizedBox(width: 12),
            Text('Agregar Widget Personalizado'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧪 Para agregar un widget personalizado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Abre el archivo widget_laboratory_screen.dart'),
            Text('2. Ve al método _buildCustomShowcase()'),
            Text('3. Agrega tu widget en el área marcada'),
            Text('4. Guarda el archivo'),
            Text('5. Usa hot reload (Ctrl+S)'),
            Text('6. Ve a la pestaña "Custom" para verlo'),
            SizedBox(height: 16),
            Text(
              'Ejemplo de código:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'TuNuevoWidget(\n  propiedad: valor,\n  onTap: () => print("test"),\n)',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                backgroundColor: Color(0xFFF5F5F5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedCategory = 'Custom';
                _tabController.animateTo(6); // Index de Custom
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: kBrandPurple),
            child: const Text('Ir a Custom',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _takeScreenshot() {
    _showSnackBar('📸 Screenshot - Función en desarrollo');
    HapticFeedback.mediumImpact();

    // TODO: Implementar captura de pantalla
    // Puedes usar packages como screenshot o flutter/rendering
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.screenshot, color: kAccentBlue),
            SizedBox(width: 12),
            Text('Screenshot'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, size: 48, color: kAccentBlue),
            SizedBox(height: 16),
            Text('Función de captura de pantalla'),
            Text('será implementada próximamente.'),
            SizedBox(height: 16),
            Text('Por ahora puedes usar:'),
            Text('• Screenshots del sistema'),
            Text('• Flutter Inspector'),
            Text('• DevTools para debugging'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: kBrandPurple,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
