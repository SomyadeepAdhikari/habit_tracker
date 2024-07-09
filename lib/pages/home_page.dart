import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    //read existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  void createHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Create a new Habit.. ',
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    //get the new habit name
                    String newHabitName = textController.text;
                    //save to db
                    context.read<HabitDatabase>().addHabit(newHabitName);

                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: Text('save',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: Text('cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                )
              ],
            ));
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    // update habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabitBox(Habit habit) {
    // set the controller text to the habit current name
    textController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Create a new Habit.. ',
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    //get the new habit name
                    String newHabitName = textController.text;
                    //save to db
                    context
                        .read<HabitDatabase>()
                        .updateHabitName(habit.id, newHabitName);

                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: Text('save',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: Text('cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                )
              ],
            ));
  }

  void deleteHabitBox(Habit habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('Are you sure you want to delete',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary)),
              actions: [
                MaterialButton(
                  onPressed: () {
                    context.read<HabitDatabase>().deleteHabit(habit.id);
                    Navigator.pop(context);
                  },
                  child: Text('delete',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: createHabit,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        body: ListView(
          children: [
            _buildHeatMap(),
            _buildHabitList(),
          ],
        ));
  }

  Widget _buildHeatMap() {
    // Habit database
    final habitDatabase = context.watch<HabitDatabase>();
    //current habit
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return heatmap ui
    return FutureBuilder<DateTime?>(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          // once the data is available build heatmap
          if (snapshot.hasData) {
            return MyHeatMap(
              startDate: snapshot.data!,
              datasets: prepareHeatMapDataSet(currentHabits),
            );
          } else {
            return Container();
          }
          // handle case where no data is returned
        });
  }

  Widget _buildHabitList() {
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return List for the habit ui
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentHabits.length,
        itemBuilder: (context, index) {
          // get each indeividual habit
          final habit = currentHabits[index];

          //check if the habit is completed today
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          //return habit tile ui
          return MyHabitTile(
            text: habit.name,
            isCompleted: isCompletedToday,
            onChanged: (value) {
              checkHabitOnOff(value, habit);
            },
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        });
  }
}
