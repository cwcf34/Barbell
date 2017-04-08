using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace APITest
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {

        private static string[] testArray = { "Registration", "Authentication & Security", "All" };
        private List<string> testList = new List<string>(testArray);

        public MainWindow()
        {
            InitializeComponent();

            //Populate the combobox
            foreach(string item in testList)
            {
                testList_comboBox.Items.Add(item);
            }
        }

        private async void runTest_button_Click(object sender, RoutedEventArgs e)
        {
            //Clear the output textblock
            output_textBlock.Text = "Running...\n";

            string testOutput = "";
            switch (testList_comboBox.Text)
            {
                case "Registration":
                    testOutput = Tests.RunRegistrationTest();
                    break;
                case "Authentication & Security":
                    testOutput = await Tests.RunSecurityTest();
                    break;
                case "All":
                    testOutput = await Tests.RunAllTests();
                    break;
                default:
                    output_textBlock.Text = "Please make a selection from the combobox.";
                    break;
            }

            output_textBlock.Text += testOutput;
        }


    }
}
