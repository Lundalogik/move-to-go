using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FruitToLime;
using NUnit.Framework;

namespace Tests
{
    [TestFixture]
    public class GoImportSerializationTests
    {
        private GoImportSerializer _importer;

        private GoImport Deserialize(string xml)
        {
            using (var stream = new MemoryStream())
            {
                var writer = new StreamWriter(stream);
                writer.Write(xml);
                writer.Flush();
                stream.Position = 0;
                return _importer.Deserialize(stream);
            }
        }

        private void AssertAddressAttributesAreNull(Address address)
        {
            Assert.That(address.City, Is.Null);
            Assert.That(address.CountryCode, Is.Null);
            Assert.That(address.Location, Is.Null);
            Assert.That(address.Street, Is.Null);
            Assert.That(address.ZipCode, Is.Null);
        }

        [SetUp]
        public void SetUp()
        {
            _importer = new GoImportSerializer();
        }

        // ReSharper disable InconsistentNaming

        [Test]
        public void Attributes_missing_in_xml_should_be_represented_with_null_in_model()
        {
            // Reason for this is that attributes should be optional in import file.
            // Otherwise we cannot sort out when something should be set to "" or should be set at all
            // and we dont always want to write since we can overwrite changes..
            var xml = @"<GoImport><Organizations> <Organization></Organization> </Organizations></GoImport>";
            var root = Deserialize(xml);

            using (var s = new MemoryStream())
            {
                // serialize and deserialize in order to make sure that our use of the classes does not introduce empty
                _importer.Serialize(s, root);
                s.Position = 0;
                var organization = _importer.Deserialize(s).Organizations.Single();

                Assert.That(organization.Id, Is.Null);
                Assert.That(organization.IntegrationId, Is.Null);
                Assert.That(organization.CentralPhoneNumber, Is.Null);
                Assert.That(organization.CustomValues, Is.Null);
                Assert.That(organization.Email, Is.Null);
                Assert.That(organization.FaxPhoneNumber, Is.Null);
                Assert.That(organization.MobilePhoneNumber, Is.Null);
                Assert.That(organization.Name, Is.Null);
                Assert.That(organization.OrganizationNumber, Is.Null);
                Assert.That(organization.Source, Is.Null);
                Assert.That(organization.WebSite, Is.Null);
                AssertAddressAttributesAreNull(organization.VisitAddress);
                AssertAddressAttributesAreNull(organization.PostalAddress);
            }
        }

    }
}
