import 'package:flutter/material.dart';

void main() {
  runApp(const RecetasApp());
}

// ─── Paleta y estilos ────────────────────────────────────────────────────────

class AppColors {
  static const Color background   = Color(0xFFF7F3EE);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color primary      = Color(0xFFD4622A);   // terracota
  static const Color primaryLight = Color(0xFFF5E6DC);
  static const Color text         = Color(0xFF2C1A0E);
  static const Color textMuted    = Color(0xFF9B8778);
  static const Color border       = Color(0xFFE8DDD4);
  static const Color heartActive  = Color(0xFFD4622A);
  static const Color heartInactive= Color(0xFFCCC4BB);
}

class AppTextStyles {
  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.3,
  );
  static const TextStyle cardDuration = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );
  static const TextStyle filterChip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
  static const TextStyle searchHint = TextStyle(
    fontSize: 14,
    color: AppColors.textMuted,
    fontStyle: FontStyle.italic,
  );
}

// ─── Modelos ─────────────────────────────────────────────────────────────────

class Receta {
  final String id;
  final String nombre;
  final String duracion;
  final String imagenUrl;
  bool esFavorita;

  Receta({
    required this.id,
    required this.nombre,
    required this.duracion,
    required this.imagenUrl,
    this.esFavorita = false,
  });
}

// ─── Root App ────────────────────────────────────────────────────────────────

class RecetasApp extends StatelessWidget {
  const RecetasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Georgia',
      ),
      home: const RecetasScreen(),
    );
  }
}

// ─── Pantalla principal ───────────────────────────────────────────────────────

class RecetasScreen extends StatefulWidget {
  const RecetasScreen({super.key});

  @override
  State<RecetasScreen> createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  // Filtro de orden
  String _ordenSeleccionado = 'reciente'; // 'reciente' | 'antiguo'
  bool _mostrandoFiltros = false;
  bool _soloFavoritos = false;

  // Filtros generales activos
  final Set<String> _filtrosActivos = {};
  final List<String> _filtrosDisponibles = [
    'Fácil',
    'Menos de 30 min',
    'Sin gluten',
    'Vegetariano',
    'Postre',
  ];

  final List<Receta> _todasLasRecetas = [
    Receta(
      id: '1',
      nombre: 'Pay de Manzana',
      duracion: '1h 15',
      imagenUrl:
          'https://images.unsplash.com/photo-1568571780765-9276ac8b75a2?w=200&q=80',
    ),
    Receta(
      id: '2',
      nombre: 'Tacos de Carnitas',
      duracion: '2h 30',
      imagenUrl:
          'https://images.unsplash.com/photo-1613514785940-daed07799d9b?w=200&q=80',
    ),
    Receta(
      id: '3',
      nombre: 'Sopa de Lima',
      duracion: '45 min',
      imagenUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=200&q=80',
    ),
    Receta(
      id: '4',
      nombre: 'Chiles en Nogada',
      duracion: '3h 00',
      imagenUrl:
          'https://images.unsplash.com/photo-1599789197514-47270cd526b4?w=200&q=80',
    ),
    Receta(
      id: '5',
      nombre: 'Pastel de Tres Leches',
      duracion: '1h 40',
      imagenUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&q=80',
    ),
  ];

  List<Receta> get _recetasFiltradas {
    List<Receta> lista = List.from(_todasLasRecetas);

    // Filtro texto
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      lista = lista
          .where((r) => r.nombre.toLowerCase().contains(query))
          .toList();
    }

    // Filtro favoritos
    if (_soloFavoritos) {
      lista = lista.where((r) => r.esFavorita).toList();
    }

    // Orden
    if (_ordenSeleccionado == 'antiguo') {
      lista = lista.reversed.toList();
    }

    return lista;
  }

  void _toggleFavorito(String id) {
    setState(() {
      final receta = _todasLasRecetas.firstWhere((r) => r.id == id);
      receta.esFavorita = !receta.esFavorita;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar reservada — espacio visible listo para implementar contenido
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        toolbarHeight: 56,
        // TODO: agregar título, logo, acciones, etc.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildBarraBusqueda(),
            if (_mostrandoFiltros) _buildPanelFiltros(),
            const SizedBox(height: 12),
            _buildDivisor(),
            Expanded(child: _buildListaRecetas()),
          ],
        ),
      ),
    );
  }

  // ─── Barra de búsqueda + controles ───────────────────────────────────────

  Widget _buildBarraBusqueda() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Campo de búsqueda
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                  fontFamily: 'Georgia',
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: AppTextStyles.searchHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Botón orden (más reciente / más antiguo)
          _buildIconBoton(
            icono: _ordenSeleccionado == 'reciente'
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            activo: true,
            tooltip: _ordenSeleccionado == 'reciente'
                ? 'Más reciente primero'
                : 'Más antiguo primero',
            onTap: () {
              setState(() {
                _ordenSeleccionado =
                    _ordenSeleccionado == 'reciente' ? 'antiguo' : 'reciente';
              });
            },
          ),

          const SizedBox(width: 8),

          // Botón filtros generales
          _buildIconBoton(
            icono: Icons.tune_rounded,
            activo: _filtrosActivos.isNotEmpty || _mostrandoFiltros,
            tooltip: 'Filtros',
            badge: _filtrosActivos.isNotEmpty
                ? _filtrosActivos.length.toString()
                : null,
            onTap: () {
              setState(() {
                _mostrandoFiltros = !_mostrandoFiltros;
              });
            },
          ),

          const SizedBox(width: 8),

          // Botón corazón (favoritos)
          _buildIconBoton(
            icono:
                _soloFavoritos ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            activo: _soloFavoritos,
            tooltip: 'Mis favoritos',
            onTap: () {
              setState(() {
                _soloFavoritos = !_soloFavoritos;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconBoton({
    required IconData icono,
    required bool activo,
    required VoidCallback onTap,
    String? tooltip,
    String? badge,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: activo ? AppColors.primaryLight : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activo ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icono,
                size: 20,
                color: activo ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Panel de filtros desplegable ─────────────────────────────────────────

  Widget _buildPanelFiltros() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _filtrosDisponibles.map((filtro) {
            final activo = _filtrosActivos.contains(filtro);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (activo) {
                    _filtrosActivos.remove(filtro);
                  } else {
                    _filtrosActivos.add(filtro);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      activo ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activo ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  filtro,
                  style: AppTextStyles.filterChip.copyWith(
                    color: activo ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Divisor decorativo ───────────────────────────────────────────────────

  Widget _buildDivisor() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: AppColors.border),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 14,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          Expanded(
            child: Container(height: 1, color: AppColors.border),
          ),
        ],
      ),
    );
  }

  // ─── Lista de recetas ─────────────────────────────────────────────────────

  Widget _buildListaRecetas() {
    final recetas = _recetasFiltradas;

    if (recetas.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _soloFavoritos
                  ? Icons.favorite_border_rounded
                  : Icons.search_off_rounded,
              size: 48,
              color: AppColors.textMuted.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              _soloFavoritos
                  ? 'No tienes favoritos aún'
                  : 'Sin resultados para tu búsqueda',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: recetas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _TarjetaReceta(
          receta: recetas[index],
          onToggleFavorito: () => _toggleFavorito(recetas[index].id),
        );
      },
    );
  }
}

// ─── Tarjeta de receta ────────────────────────────────────────────────────────

class _TarjetaReceta extends StatefulWidget {
  final Receta receta;
  final VoidCallback onToggleFavorito;

  const _TarjetaReceta({
    required this.receta,
    required this.onToggleFavorito,
  });

  @override
  State<_TarjetaReceta> createState() => _TarjetaRecetaState();
}

class _TarjetaRecetaState extends State<_TarjetaReceta>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.4)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.4, end: 1.0)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 50),
    ]).animate(_heartCtrl);
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _onTapCorazon() {
    widget.onToggleFavorito();
    _heartCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            child: Image.network(
              widget.receta.imagenUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 96,
                  height: 96,
                  color: AppColors.primaryLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                width: 96,
                height: 96,
                color: AppColors.primaryLight,
                child: const Icon(
                  Icons.image_not_supported_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),

          // Info central
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.receta.nombre,
                    style: AppTextStyles.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.receta.duracion,
                        style: AppTextStyles.cardDuration,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Corazón con animación
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _onTapCorazon,
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _heartScale,
                builder: (_, __) => Transform.scale(
                  scale: _heartScale.value,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: Icon(
                      widget.receta.esFavorita
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(widget.receta.esFavorita),
                      size: 24,
                      color: widget.receta.esFavorita
                          ? AppColors.heartActive
                          : AppColors.heartInactive,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}