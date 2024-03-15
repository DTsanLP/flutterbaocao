import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart';
import 'package:csv/csv.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hệ thống thông tin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(body: App()),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedNavIndex = -1; // Biến lưu trạng thái của các nút navigation
  int _selectedContR1 = -1; //Biến lưu trạng thái nút R1
  int _preNavButton = -1; // Biến lưu trữ trạng thái của nút navigation trước đó
  String _selectedNavLabel = '';
  String _selectedR1Label = '';
  List<List<dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
    loadCSV();
  }


  Future<void> loadCSV() async {
    final String csvString = await rootBundle.loadString('assets/csv/temp.csv');
    List<List<dynamic>> parsedCSV = CsvToListConverter().convert(csvString);
    setState(() {
      csvData = parsedCSV;
    });
  }

  Widget build(BuildContext context) {
    return Container(
      color: Colors
          .grey[200], // Assuming background is a variable defined elsewhere
      child: LayoutGrid(
        // New ASCII-art named areas
        areas: '''
          header header header header header
          temp   r1     r1     r1     r1
          nav    r2     r2     r2     r2
          nav    r3     r3     r3     r3
          nav    script script script script
        ''',
        // Updated concise track sizing methods
        columnSizes: [150.px, 1.fr, 1.fr, 1.fr, 1.fr],
        rowSizes: [
          100.px,
          50.px,
          50.px,
          50.px,
          1.fr,
        ],
        // Updated column and row gaps to zero
        columnGap: 0, // no gap between columns
        rowGap: 0, // no gap between rows
        // Handy grid placement extension methods on Widget
        children: [
          const Header().inGridArea('header'),
          // Temp should be defined if it's different from Navigation
          Temp(
            selectedNavIndex: _selectedNavIndex,
            selectedNavLabel: _selectedNavLabel,
          ).inGridArea('temp'),
          Navigation(
            onNavButtonPressed: (index, text) {
              setState(() {
                _preNavButton = _selectedNavIndex;
                _selectedNavIndex = index;
                _selectedNavLabel = text;
              });
            },
          ).inGridArea('nav'),
          // Define content for r1, r2, r3, and script areas
          ContentR1(
            navStatus: _preNavButton,
            selectedNavIndex: _selectedNavIndex,
            onContR1Pressed: (index, text) {
              setState(() {
                _selectedContR1 = index;
                _selectedR1Label = text;
              });
            },
          ).inGridArea('r1'),
          ContentR2(
                  selectedContR1: _selectedContR1,
                  selectedNavIndex: _selectedNavIndex)
              .inGridArea('r2'),
          ContentR3(
                  selectedContR1: _selectedContR1,
                  selectedNavIndex: _selectedNavIndex)
              .inGridArea('r3'),
          Script(
              selectedContR1: _selectedContR1,
              selectedNavIndex: _selectedNavIndex,
            selectedR1Label: _selectedR1Label,
              selectedNavLabel: _selectedNavLabel,
              csvData: csvData,
          ).inGridArea('script'),
          // Footer has been removed as it's not specified in the new grid areas
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20, left: 50),
            child: Text(
              'HỆ THỐNG THÔNG TIN KINH TẾ XÃ HỘI TỈNH BÌNH ĐỊNH',
              style: TextStyle(
                //fontWeight: FontWeight.bold,
                fontSize: 35,
                letterSpacing: 1.0,
                color: Colors.white,
                height: 2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextButton(
              onPressed: () {
                // Xử lý sự kiện khi nút đăng nhập được nhấn
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const LoginDialog();
                  },
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Danh sách các tài khoản
  final List<Map<String, String>> _accounts = [
    {'username': 'user1', 'password': 'password1'},
    {'username': 'user2', 'password': 'password2'},
    // Thêm các tài khoản khác nếu cần
  ];

  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đăng nhập'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Tên đăng nhập',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu',
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Kiểm tra thông tin đăng nhập với danh sách tài khoản
            bool isAuthenticated = false;
            for (var account in _accounts) {
              if (account['username'] == _usernameController.text &&
                  account['password'] == _passwordController.text) {
                isAuthenticated = true;
                break;
              }
            }

            if (isAuthenticated) {
              // Đóng cửa sổ nếu đăng nhập thành công
              Navigator.of(context).pop();
            } else {
              // Hiển thị thông báo lỗi nếu đăng nhập không thành công
              setState(() {
                _errorMessage = 'Tên đăng nhập hoặc mật khẩu không chính xác';
              });
            }
          },
          child: const Text('Đăng nhập'),
        ),
        TextButton(
          onPressed: () {
            // Đóng cửa sổ khi nút hủy được nhấn
            Navigator.of(context).pop();
          },
          child: const Text('Hủy'),
        ),
      ],
    );
  }
}
class Temp extends StatefulWidget{
  final int selectedNavIndex;
  final String selectedNavLabel;
  const Temp({
    Key? key,
    required this.selectedNavIndex,
    required this.selectedNavLabel,
}):super (key:key);
  @override
  _TempState createState() => _TempState();
}

class _TempState extends State<Temp> {
  @override
  Widget build(BuildContext context) {
    if (widget.selectedNavIndex != -1)
      {
        return Container(
          alignment: Alignment.center,
          width: double.infinity,
          color: const Color.fromARGB(255, 39, 43, 143),
          child: Text(
            widget.selectedNavLabel,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              height: 3,
            ),
          ),
        );
      }
    return Container(color: const Color.fromARGB(255, 39, 43, 143), child: const Center());
  }
}

class Navigation extends StatefulWidget {
  final Function(int index, String text) onNavButtonPressed; // Hàm callback để thông báo về việc nút navigation được nhấn
  const Navigation({
    Key? key,
    required this.onNavButtonPressed,
  }) : super(key: key);

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final Color _buttonColor = const Color.fromARGB(255, 39, 43, 143);
  final Color _textColor = Colors.white;
  int _selectedIndex = -1;
  String _selectedLabel = '';
  final List<bool> _showWards =  List<bool>.filled(10, false); // Biến để theo dõi trạng thái hiển thị phường
  final IconData _arrowIcon = Icons.menu_outlined;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Sử dụng SingleChildScrollView để cho phép cuộn trang khi cần thiết
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          buildTextButton('Tỉnh Bình Định', 0),
          buildTextButton('Tp.Quy Nhơn', 1),
          if (_showWards[1]) ...[
            buildTextButton('P.Nhơn Bình', -2),
            buildTextButton('P.Nhơn Phú', -3),
            buildTextButton('P.Đống Đa 3', -4),
            buildTextButton('P.Trần Quang Diệu', -5),
            buildTextButton('P.Hải Cảng', -6),
            buildTextButton('P.Quang Trung', -7),
            buildTextButton('P.Thị Nại', -8),
            buildTextButton('P.Lê Hồng Phong', -9),
            const Text('  '),
          ],
          if (_selectedIndex == 1 )
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(_arrowIcon),
                  onPressed: () {
                    setState(() {
                      _showWards[1] = !_showWards[1];
                    });
                  },
                ),
              ],
            ),
          buildTextButton('H.Tuy Phước', 2),
            if (_showWards[2]) ...[
              buildTextButton('TT.Tuy Phước', -10),
              buildTextButton('TT.Diêu Trì', -11),
              buildTextButton('X.Phước Thắng', -12),
              buildTextButton('X.Phước Quang', -13),
              buildTextButton('X.Phước Hòa', -14),
              buildTextButton('X.Phước Sơn', -15),
              buildTextButton('X.Phước Hiệp', -16),
              const Text('  '),
            ],
            if (_selectedIndex == 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(_arrowIcon),
                    onPressed: () {
                      setState(() {
                        _showWards[2] = !_showWards[2];
                      });
                    },
                  ),
                ],
              ),
          buildTextButton('H.Phù Cát', 3),
          buildTextButton('TX. An Nhơn', 4),
    ],
        ),
      ),
    );
  }

  Widget buildTextButton(String text, int index) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
          _selectedLabel = text;
          if (index >= 0) {
            _showWards[index] = false;
            // Ẩn danh sách phường khi chọn các mục khác
          }
        });
        // Gọi hàm callback để thông báo rằng nút navigation được nhấn
        widget.onNavButtonPressed(_selectedIndex, _selectedLabel );
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          _selectedIndex == index ? _textColor : _buttonColor,
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        overlayColor: MaterialStateProperty.all(_textColor.withOpacity(0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: TextStyle(
            fontSize: index >= 0 ? 16 : 13,
            fontWeight: index >= 0 ? FontWeight.bold : FontWeight.normal,
            color: _selectedIndex == index ? _buttonColor : _textColor,
            height: 3,
          ),
        ),
      ),
    );
  }
}

class ContentR1 extends StatefulWidget {
  final int navStatus;
  final int selectedNavIndex; // Bđược nhấn
  final Function(int index, String text) onContR1Pressed;
  const ContentR1({
    Key? key,
    required this.navStatus,
    required this.selectedNavIndex,
    required this.onContR1Pressed,
  }) : super(key: key);
  @override
  _ContentR1State createState() => _ContentR1State();
}

class _ContentR1State extends State<ContentR1> {
  final Color _buttonColor = const Color.fromARGB(255, 39, 43, 143);
  final Color _textColor = Colors.white;
  int _selectedIndex = 0;
  String _selectedLabel = '';
  bool _checkNavStatus() {
    return widget.selectedNavIndex != widget.navStatus ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _buttonColor,
      height: MediaQuery
          .of(context)
          .size
          .height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextButton('Tổng quan ${widget.selectedNavIndex}', 0),
          buildTextButton('Biểu đồ thống kê $_selectedIndex', 1),
          buildTextButton('Quản lí dữ liệu ${widget.navStatus}', 2),
          buildTextButton('Quản lí cán bộ', 3),
        ],
      ),
    );
  }

//   Widget buildTextButton(String text, int index) {
//     if (_checkNavStatus() && index == 0 ) {
//       //_buttonColor =
//       //return Container();
//     }
//     return TextButton(
//       onPressed: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//         widget.onContR1Pressed(index);
//       },
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.all(
//           _selectedIndex == index ? _textColor : _buttonColor,
//         ),
//         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//           RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(0),
//           ),
//         ),
//         overlayColor: MaterialStateProperty.all(_textColor.withOpacity(0.5)),
//       ),
//       child: SizedBox(
//         height: double.infinity,
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: _selectedIndex == index ? _buttonColor : _textColor,
//             height: 3,
//           ),
//         ),
//       ),
//     );
//   }
// }
  Widget buildTextButton(String text, int index) {
    // Tạo một biến để lưu trạng thái màu sắc của nút đầu tiên
    Color buttonTextColor = _textColor;
    Color buttonBackgroundColor = _buttonColor;

    // Kiểm tra xem nút đầu tiên có được chọn không
    if (_checkNavStatus() && _selectedIndex != 0) {
      // Nếu đúng, đặt màu sắc khác cho nút đầu tiên
      buttonTextColor = _textColor;
      buttonBackgroundColor = _buttonColor;
    }
    // Kiểm tra xem nút đang được xây dựng có trùng với _selectedIndex không
    // if (_selectedIndex == index) {
    //   buttonTextColor = _buttonColor;
    //   buttonBackgroundColor = _textColor;
    // }
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
          _selectedLabel = text;
        });
        widget.onContR1Pressed(index, text);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(buttonBackgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        overlayColor: MaterialStateProperty.all(_textColor.withOpacity(0.5)),
      ),
      child: SizedBox(
        height: double.infinity,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: buttonTextColor,
            height: 3,
          ),
        ),
      ),
    );
  }
}
class ContentR2 extends StatefulWidget {
  final int selectedContR1;
  final int selectedNavIndex;
  const ContentR2({
    Key? key,
    required this.selectedContR1,
    required this.selectedNavIndex,
  }) : super(key: key);
  @override
  _ContentR2State createState() => _ContentR2State();
}

class _ContentR2State extends State<ContentR2> {
  final Color _buttonColor = const Color.fromARGB(255, 39, 43, 143);
  final Color _textColor = Colors.white70;
  int _selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    if (widget.selectedContR1 != 0) {
      return Container();
    }
    return Container(
        color: Colors.white70,
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildTextButton('Chỉ tiêu kinh tế tổng hợp $_selectedIndex', 0),
            buildTextButton('Công nghiệp', 1),
            buildTextButton('Dịch vụ', 2),
            buildTextButton('Dân cư', 3),
          ],
        ));
  }

  Widget buildTextButton(String text, int index) {
    return TextButton(
      onPressed: () {
        // _handleButtonPress();
        setState(() {
          _selectedIndex = index;
        });
        // Gọi hàm callback để thông báo rằng nút navigation được nhấn
        //widget.onNavButtonPressed(_selectedIndex);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.white70,
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        overlayColor: MaterialStateProperty.all(_buttonColor.withOpacity(0.5)),
      ),
      child: SizedBox(
        height: double.infinity,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _buttonColor,
            height: 3,
          ),
        ),
      ),
    );
  }
}

class ContentR3 extends StatefulWidget {
  final int selectedNavIndex; // Biến lưu trạng thái của nút navigation
  final int selectedContR1;
  const ContentR3({
    Key? key,
    required this.selectedNavIndex,
    required this.selectedContR1,
  }) : super(key: key);
  @override
  _ContentR3State createState() => _ContentR3State();
}

class _ContentR3State extends State<ContentR3> {
  final Color _buttonColor = const Color.fromARGB(255, 39, 43, 143);
  final Color _textColor = Colors.white;
  int _selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    if (widget.selectedContR1 != 0) {
      return Container();
    }
    return Container(
        color: Colors.white70,
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildTextButton('Tổng quan nông, lâm nghiệp, thủy sản ', 0),
            buildTextButton('Nông nghiệp', 1),
            buildTextButton('Lâm nghiệp', 2),
            buildTextButton('Thủy sản', 3),
          ],
        ));
  }

  Widget buildTextButton(String text, int index) {
    return TextButton(
      onPressed: () {
        // _handleButtonPress();
        setState(() {
          _selectedIndex = index;
        });
        // Gọi hàm callback để thông báo rằng nút navigation được nhấn
        //widget.onNavButtonPressed(_selectedIndex);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white70),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        overlayColor: MaterialStateProperty.all(_buttonColor.withOpacity(0.5)),
      ),
      child: SizedBox(
        height: double.infinity,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _buttonColor,
            height: 3,
          ),
        ),
      ),
    );
  }
}

class Script extends StatefulWidget {
  final int selectedNavIndex;
  final int selectedContR1;
  final String selectedNavLabel;
  final String selectedR1Label;
  final List<List<dynamic>> csvData;
  const Script({
    Key? key,
    required this.selectedNavIndex,
    required this.selectedContR1,
    required this.csvData,
    required this.selectedNavLabel,
    required this.selectedR1Label,
  }) : super(key: key);

  @override
  _ScriptState createState() => _ScriptState();
}

class _ScriptState extends State<Script> {

  List<_ChartData> chartData = [
    _ChartData('2014', 11106, 16106, 20106),
    _ChartData('2015', 10109, 14106, 19062),
    _ChartData('2016', 10446, 10106, 18916),
    _ChartData('2017', 10105, 10106, 18200),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Color.fromRGBO(214, 226, 240, 1),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.pink,
                      width: 200,
                      height: 50,
                      alignment: Alignment.topLeft,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(widget.selectedNavLabel),
                            Text(" > "),
                            Text(widget.selectedR1Label),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(2.0), // Adjust padding as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.red,
                      width: 400,
                      height: 300,
                      child: ListView.builder(
                        itemCount: widget.csvData.length,
                        itemBuilder: (context, index) {
                          return Card(
                              margin: const EdgeInsets.all(10),
                              color: index == 0 ? Colors.amber : Colors.white,


                              /* child: ListTile(
                              title: Text('${csvData[index][0]}'.toString()),
                              subtitle: Text('${csvData[index][1]}'.toString()),
                              trailing: Text('${csvData[index][2]}'.toString()),
                            ), */
                              child: Row(
                                  children: [
                                    SfCartesianChart(
                                      primaryXAxis: CategoryAxis(),
                                      primaryYAxis: NumericAxis(labelFormat: '{value} Tỷ đồng'),
                                      title: ChartTitle(text: 'Doanh thu Nông nghiệp, Lâm nghiệp và Thủy sản'),
                                      // Chart title
                                      // Enable legend
                                      legend: Legend(isVisible: true),
                                      // Enable tooltip
                                      tooltipBehavior: TooltipBehavior(enable: true),
                                      series: <CartesianSeries<_ChartData, String>>[
                                        StackedColumnSeries<_ChartData, String>(
                                            dataSource: chartData,
                                            xValueMapper: (_ChartData data, _) => data.year,
                                            yValueMapper: (_ChartData data, _) => data.agriculture,
                                            name: 'Nông nghiệp',
                                            color: Colors.red,
                                            // Enable data label
                                            dataLabelSettings: DataLabelSettings(isVisible: true)),
                                        StackedColumnSeries<_ChartData, String>(
                                          dataSource: chartData,
                                          xValueMapper: (_ChartData data, _) => data.year,
                                          yValueMapper: (_ChartData data, _) => data.forestry,
                                          name: 'Lâm nghiệp',
                                          color: Colors.yellow,
                                        ),
                                        StackedColumnSeries<_ChartData, String>(
                                          dataSource: chartData,
                                          xValueMapper: (_ChartData data, _) => data.year,
                                          yValueMapper: (_ChartData data, _) => data.aquaculture,
                                          name: 'Thủy sản',
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ]));
                        },
                      ),
                    ),
                    SizedBox(height: 16), // Adjust the height of the padding between the containers
                    Container(
                      color: Colors.red,
                      width: 400,
                      height: 300,
                      child: ListView.builder(
                        itemCount: widget.csvData.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(3),
                            color: index == 0 ? Colors.amber : Colors.white,
                            child: ListTile(
                              leading: Text('${widget.csvData[index][0]}'.toString()),
                              subtitle: Text('${widget.csvData[index][1]}'.toString()),
                              trailing: Text('${widget.csvData[index][2]}'.toString()),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ChartData {
  _ChartData(this.year, this.agriculture, this.forestry, this.aquaculture);

  final String year;
  final double agriculture;
  final double forestry;
  final double aquaculture;
}