using FruitToLime.Extra;

namespace FruitToLime
{
    public partial class Organization : IWithCustomValues, IWithTags, IWithSource
    {
        public Organization()
        {
            PostalAddress = new Address();
            VisitAddress = new Address();
        }
    }
}