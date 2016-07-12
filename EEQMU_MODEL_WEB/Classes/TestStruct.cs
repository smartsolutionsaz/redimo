using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WEB_PLATFORM007.Classes {
    public struct Person {
        private static int count = 0;

        public string name;
        public string surname;
        public readonly int index;

        public Person(string name, string surname) {
            this.name = name;
            this.surname = surname;
            this.index = count++;
        }

        public string toString() {
            return $"{index} {name} {surname}";
        }
    }
}