using System;
using System.Collections.Generic;

namespace MyApp.Utils
{
    public class StringHelper
    {
        private string data;

        public StringHelper(string initialData)
        {
            data = initialData;
        }

        public string Reverse()
        {
            char[] arr = data.ToCharArray();
            Array.Reverse(arr);
            return new string(arr);
        }

        public List<string> Split(char delimiter)
        {
            return new List<string>(data.Split(delimiter));
        }
    }
}
