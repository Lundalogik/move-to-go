using FruitToLime.Extra;

namespace FruitToLime
{
    public partial class Person : IWithCustomValues, IWithTags, IWithSource
    {
        public Person()
        {
            PostalAddress = new Address();
            CurrentlyEmployed = true;
        }
    }
}