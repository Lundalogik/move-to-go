using FruitToLime;
using NUnit.Framework;

namespace Tests
{
    [TestFixture]
    public class ApiClassesTests
    {
        // ReSharper disable InconsistentNaming
        [Test]
        public void Addresses_on_organization_is_not_null()
        {
            var organization = new Organization();
            Assert.NotNull(organization.VisitAddress);
            Assert.NotNull(organization.PostalAddress);
        }

        [Test]
        public void Addresses_on_person_is_not_null()
        {
            var person = new Person();
            Assert.NotNull(person.PostalAddress);
        }

        [Test]
        public void A_person_should_be_employed_by_default()
        {
            var person = new Person();
            Assert.That(person.CurrentlyEmployed,Is.True);
        }
    }
}