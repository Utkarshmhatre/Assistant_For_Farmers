import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum FarmEventType {
  sowing,
  irrigation,
  fertilizer,
  pesticide,
  harvest,
  market,
  veterinary,
  maintenance,
  other
}

extension FarmEventTypeExtension on FarmEventType {
  String get label {
    switch (this) {
      case FarmEventType.sowing:
        return 'Sowing';
      case FarmEventType.irrigation:
        return 'Irrigation';
      case FarmEventType.fertilizer:
        return 'Fertilizer';
      case FarmEventType.pesticide:
        return 'Pesticide';
      case FarmEventType.harvest:
        return 'Harvest';
      case FarmEventType.market:
        return 'Market';
      case FarmEventType.veterinary:
        return 'Veterinary';
      case FarmEventType.maintenance:
        return 'Maintenance';
      case FarmEventType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case FarmEventType.sowing:
        return Icons.scatter_plot;
      case FarmEventType.irrigation:
        return Icons.water_drop;
      case FarmEventType.fertilizer:
        return Icons.eco;
      case FarmEventType.pesticide:
        return Icons.bug_report;
      case FarmEventType.harvest:
        return Icons.agriculture;
      case FarmEventType.market:
        return Icons.store;
      case FarmEventType.veterinary:
        return Icons.medical_services;
      case FarmEventType.maintenance:
        return Icons.build;
      case FarmEventType.other:
        return Icons.task_alt;
    }
  }

  Color get color {
    switch (this) {
      case FarmEventType.sowing:
        return Colors.brown;
      case FarmEventType.irrigation:
        return Colors.blue;
      case FarmEventType.fertilizer:
        return Colors.green;
      case FarmEventType.pesticide:
        return Colors.orange;
      case FarmEventType.harvest:
        return Colors.amber;
      case FarmEventType.market:
        return Colors.purple;
      case FarmEventType.veterinary:
        return Colors.red;
      case FarmEventType.maintenance:
        return Colors.grey;
      case FarmEventType.other:
        return Colors.teal;
    }
  }
}

class FarmEvent {
  final String id;
  final String title;
  final String notes;
  final DateTime date;
  final TimeOfDay? time;
  final FarmEventType type;
  bool isDone;
  FarmEvent({
    required this.id,
    required this.title,
    required this.notes,
    required this.date,
    this.time,
    required this.type,
    this.isDone = false,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'date': date.millisecondsSinceEpoch,
      'time':
          time != null ? {'hour': time!.hour, 'minute': time!.minute} : null,
      'type': type.index,
      'isDone': isDone,
    };
  }

  factory FarmEvent.fromJson(Map<String, dynamic> json) {
    return FarmEvent(
      id: json['id'],
      title: json['title'],
      notes: json['notes'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      time: json['time'] != null
          ? TimeOfDay(
              hour: json['time']['hour'], minute: json['time']['minute'])
          : null,
      type: FarmEventType.values[json['type']],
      isDone: json['isDone'] ?? false,
    );
  }
}

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  Map<String, List<FarmEvent>> _events = {};
  List<FarmEvent> _selectedEvents = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<FarmEventType> _selectedTypes = {};
  bool _hideDone = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('farm_events') ?? '{}';
    final Map<String, dynamic> decoded = json.decode(eventsJson);

    setState(() {
      _events = decoded.map((key, value) => MapEntry(
            key,
            (value as List)
                .map((eventJson) => FarmEvent.fromJson(eventJson))
                .toList(),
          ));
      _updateSelectedEvents();
    });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = json.encode(_events.map((key, value) => MapEntry(
          key,
          value.map((event) => event.toJson()).toList(),
        )));
    await prefs.setString('farm_events', eventsJson);
  }

  void _updateSelectedEvents() {
    final dateKey = _dateKey(_selectedDay);
    List<FarmEvent> events = _events[dateKey] ?? [];

    // Apply filters
    if (_searchQuery.isNotEmpty) {
      events = events
          .where((event) =>
              event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              event.notes.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedTypes.isNotEmpty) {
      events =
          events.where((event) => _selectedTypes.contains(event.type)).toList();
    }

    if (_hideDone) {
      events = events.where((event) => !event.isDone).toList();
    }

    setState(() {
      _selectedEvents = events;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _updateSelectedEvents();
    });
  }

  List<FarmEvent> _getEventsForDay(DateTime day) {
    final dateKey = _dateKey(day);
    return _events[dateKey] ?? [];
  }

  void _addEvent(FarmEvent event) {
    final dateKey = _dateKey(event.date);
    setState(() {
      if (_events[dateKey] != null) {
        _events[dateKey]!.add(event);
      } else {
        _events[dateKey] = [event];
      }
      _updateSelectedEvents();
    });
    _saveEvents();
  }

  void _toggleEventDone(FarmEvent event) {
    setState(() {
      event.isDone = !event.isDone;
      _updateSelectedEvents();
    });
    _saveEvents();
  }

  void _deleteEvent(FarmEvent event) {
    final dateKey = _dateKey(event.date);
    setState(() {
      _events[dateKey]?.remove(event);
      if (_events[dateKey]?.isEmpty ?? false) {
        _events.remove(dateKey);
      }
      _updateSelectedEvents();
    });
    _saveEvents();
  }

  void _undoDelete(FarmEvent event, int index) {
    final dateKey = _dateKey(event.date);
    setState(() {
      if (_events[dateKey] != null) {
        _events[dateKey]!.insert(index, event);
      } else {
        _events[dateKey] = [event];
      }
      _updateSelectedEvents();
    });
    _saveEvents();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Farm Tasks & Events',
            style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: keyboardHeight + 16.0,
        ),
        child: CustomScrollView(
          slivers: [
            // Calendar Section
            SliverToBoxAdapter(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Calendar',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                    _calendarFormat == CalendarFormat.month
                                        ? Icons.view_week
                                        : Icons.view_module),
                                onPressed: () {
                                  setState(() {
                                    _calendarFormat =
                                        _calendarFormat == CalendarFormat.month
                                            ? CalendarFormat.week
                                            : CalendarFormat.month;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TableCalendar<FarmEvent>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: _onDaySelected,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        eventLoader: _getEventsForDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          weekendTextStyle:
                              TextStyle(color: Colors.red.shade400),
                          holidayTextStyle:
                              TextStyle(color: Colors.red.shade400),
                          selectedDecoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: theme.textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search and Filters Section
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _updateSelectedEvents();
                      });
                    },
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle:
                          TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(Icons.search,
                          color: theme.colorScheme.onSurfaceVariant),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: theme.colorScheme.onSurfaceVariant),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _updateSelectedEvents();
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    scrollPadding:
                        EdgeInsets.only(bottom: keyboardHeight + 100),
                  ),

                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Hide Done'),
                          selected: _hideDone,
                          onSelected: (selected) {
                            setState(() {
                              _hideDone = selected;
                              _updateSelectedEvents();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ...FarmEventType.values.map((type) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                avatar: Icon(type.icon, size: 16),
                                label: Text(type.label),
                                selected: _selectedTypes.contains(type),
                                selectedColor:
                                    type.color.withValues(alpha: 0.2),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedTypes.add(type);
                                    } else {
                                      _selectedTypes.remove(type);
                                    }
                                    _updateSelectedEvents();
                                  });
                                },
                              ),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date Header with Task Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tasks for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          if (_getEventsForDay(_selectedDay)
                              .where((e) => !e.isDone)
                              .isNotEmpty)
                            Chip(
                              label: Text(
                                  '${_getEventsForDay(_selectedDay).where((e) => !e.isDone).length} Pending'),
                              backgroundColor: theme.colorScheme.errorContainer,
                              labelStyle: TextStyle(
                                  color: theme.colorScheme.onErrorContainer),
                            ),
                          const SizedBox(width: 8),
                          if (_getEventsForDay(_selectedDay)
                              .where((e) => e.isDone)
                              .isNotEmpty)
                            Chip(
                              label: Text(
                                  '${_getEventsForDay(_selectedDay).where((e) => e.isDone).length} Done'),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Tasks List
            _selectedEvents.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty ||
                                      _selectedTypes.isNotEmpty ||
                                      _hideDone
                                  ? 'No tasks match your filters'
                                  : 'No tasks for this day',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = _selectedEvents[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Dismissible(
                            key: Key(event.id),
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  const Icon(Icons.check, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                _toggleEventDone(event);
                              } else {
                                final eventCopy = event;
                                final eventIndex = index;
                                _deleteEvent(event);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Task deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () =>
                                          _undoDelete(eventCopy, eventIndex),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      event.type.color.withValues(alpha: 0.15),
                                  child: Icon(
                                    event.type.icon,
                                    color: event.type.color,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  event.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: event.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: event.isDone
                                        ? theme.colorScheme.onSurfaceVariant
                                        : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (event.time != null)
                                      Text(
                                        'Time: ${event.time!.format(context)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    if (event.notes.isNotEmpty)
                                      Text(
                                        event.notes,
                                        style: theme.textTheme.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        event.isDone
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: event.isDone
                                            ? Colors.green
                                            : theme
                                                .colorScheme.onSurfaceVariant,
                                      ),
                                      onPressed: () => _toggleEventDone(event),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red,
                                      onPressed: () => _deleteEvent(event),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _selectedEvents.length,
                    ),
                  ),

            // Bottom Padding for Keyboard
            SliverToBoxAdapter(
              child: SizedBox(height: 100 + keyboardHeight),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskBottomSheet(
        onAddTask: _addEvent,
        selectedDate: _selectedDay,
      ),
    );
  }
}

class AddTaskBottomSheet extends StatefulWidget {
  final Function(FarmEvent) onAddTask;
  final DateTime selectedDate;

  const AddTaskBottomSheet({
    super.key,
    required this.onAddTask,
    required this.selectedDate,
  });

  @override
  _AddTaskBottomSheetState createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  FarmEventType _selectedType = FarmEventType.other;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: keyboardHeight + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Add New Task',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Task Type Selection
          Text(
            'Task Type',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FarmEventType.values.map((type) {
              final isSelected = _selectedType == type;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = type;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? type.color
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected ? type.color : theme.colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type.icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Task Title
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Task Title *',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(_selectedType.icon),
            ),
          ),
          const SizedBox(height: 16),

          // Time Selection
          InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  _selectedTime = time;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime != null
                        ? 'Time: ${_selectedTime!.format(context)}'
                        : 'Add Time (Optional)',
                    style: TextStyle(
                      color: _selectedTime != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedTime != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _selectedTime = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes (Optional)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.note),
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _titleController.text.trim().isEmpty
                      ? null
                      : () {
                          final event = FarmEvent(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title: _titleController.text.trim(),
                            notes: _notesController.text.trim(),
                            date: widget.selectedDate,
                            time: _selectedTime,
                            type: _selectedType,
                          );
                          widget.onAddTask(event);
                          Navigator.pop(context);
                        },
                  child: const Text('Save Task'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
