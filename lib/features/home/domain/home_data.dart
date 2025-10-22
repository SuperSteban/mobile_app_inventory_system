// lib/features/home/domain/home_data.dart

import 'package:flutter/material.dart';

class StatItem {
  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final Color trendColor;

  StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendColor,
  });
}

class QuickActionItem {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color bgColor;

  QuickActionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.bgColor,
  });
}

class ActivityItem {
  final String title;
  final String description;
  final String time;
  final Color indicatorColor;

  ActivityItem({
    required this.title,
    required this.description,
    required this.time,
    required this.indicatorColor,
  });
}

final List<StatItem> statsData = [
  StatItem(
    icon: Icons.inventory_2_outlined,
    value: "2,543",
    label: "Productos",
    trend: "+12%",
    trendColor: Colors.green,
  ),
  StatItem(
    icon: Icons.bar_chart_sharp,
    value: "89%",
    label: "Eficiencia",
    trend: "+5%",
    trendColor: Colors.green,
  ),
  StatItem(
    icon: Icons.schedule,
    value: "24h",
    label: "Respuesta",
    trend: "-8%",
    trendColor: Colors.red, // Tendencia negativa en rojo
  ),
];

final List<QuickActionItem> quickActionsData = [
  QuickActionItem(
    icon: Icons.stars,
    title: "Nuevo Registro",
    description: "Añadir nuevo producto",
    iconColor: Colors.blue.shade800,
    bgColor: Colors.blue.shade50,
  ),
  QuickActionItem(
    icon: Icons.trending_up,
    title: "Ver Reportes",
    description: "Análisis y estadísticas",
    iconColor: Colors.orange.shade800,
    bgColor: Colors.orange.shade50,
  ),
  QuickActionItem(
    icon: Icons.bolt,
    title: "Acceso Rápido",
    description: "Funciones frecuentes",
    iconColor: Colors.blue.shade800,
    bgColor: Colors.blue.shade50,
  ),
];

final List<ActivityItem> recentActivitiesData = [
  ActivityItem(
    title: "Actualización de Inventario",
    description: "Se registraron 15 nuevos productos",
    time: "Hace 2 horas",
    indicatorColor: Colors.green,
  ),
  ActivityItem(
    title: "Reporte Generado",
    description: "Reporte mensual disponible",
    time: "Hace 5 horas",
    indicatorColor: Colors.blue,
  ),
  ActivityItem(
    title: "Alerta de Stock",
    description: "3 productos con stock bajo",
    time: "Hace 1 día",
    indicatorColor: Colors.amber,
  ),
];