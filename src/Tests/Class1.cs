using FruitToLime;
using FruitToLime.Extra;
using NUnit.Framework;

namespace Tests
{
    [TestFixture]
    public class ValidateAgainstXsd
    {
        private GoImport i;
        [SetUp]
        public void SetUp()
        {
            i = new GoImport();
            i.Settings.WithOrganization(s =>
            {
                s.SetCustomField(integrationId: "2", title: "cf title");
                s.SetCustomField(integrationId: "3", title: "cf title2");
            });
            var o = new Organization {Name = "Ankeborgs bibliotek"};
            o.WithSource(source =>
                source.ParSe("122345"));

            o.AddTag("tag:bibliotek");
            o.AddTag("tag:Björk");
            o.SetCustomField(integrationId: "2", value: "cf value");
            o.SetCustomField(integrationId: "3", value: "cf Björk");
            o.WithPostalAddress(addr =>
                addr.City = "Ankeborg"
                );
            o.WithVisitAddress(addr =>
                addr.City = "Gaaseborg"
                );

            o.AddResponsibleCoworker(
                integrationId: "1"
                );
            var emp = o.AddEmployee(
                integrationId: "1",
                firstName: "Kalle",
                lastName: "Anka"
                );
            emp.DirectPhoneNumber = "234234234";
            emp.CurrentlyEmployed = true;
            i.AddOrganization(o);
            //xsd_file = Path.Combine(File.dirname(__FILE__), '..', 'sample_data', 'schema0.xsd')
            // TODO: Serialize import
        }

        [Test]
        public void Validate()
        {
            Assert.Fail("Not implemented");
        }
    }
}
