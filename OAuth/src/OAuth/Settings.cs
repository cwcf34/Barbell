using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace OAuth
{
    public class Settings
    {
        public static string redispw
        {
            get
            {
                try
                {
                    var fileStream = new FileStream(@"C:\secrets\apiConfig.txt", FileMode.Open, FileAccess.Read);
                    var streamReader = new StreamReader(fileStream);
                    return streamReader.ReadLine();
                }
                catch
                {
                    return "";
                }
            }
        }
    }
}
