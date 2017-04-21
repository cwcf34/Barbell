using System;

namespace BBAPI.Models
{
    public class ExerciseData
    {
        public DateTime Date { get; set; }
        public int Sets { get; set; }
        public int Reps { get; set; }
        public int Weight { get; set; } 

        public ExerciseData(DateTime date, int sets, int reps, int weight)
        {
            Date = date;
            Sets = sets;
            Reps = reps;
            Weight = weight;
        }
    }
}