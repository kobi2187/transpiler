namespace MyApp.Models
{
    public interface IRepository<T>
    {
        T Get(int id);
        void Save(T item);
    }

    public class User
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public class UserRepository : IRepository<User>
    {
        public User Get(int id)
        {
            return new User { Id = id, Name = "Test" };
        }

        public void Save(User item)
        {
            // Save logic here
        }
    }
}
