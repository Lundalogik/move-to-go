using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Schema;
using FruitToLime;
using FruitToLime.Extra;
using NUnit.Framework;

namespace Tests
{
    [TestFixture]
    public class GeneratedImportFile
    {
        private GoImport _i;
        private string _xsdFile;
        private MemoryStream _stream;

        [SetUp]
        public void SetUp()
        {
            _i = new GoImport();
            _i.Settings.WithOrganization(s =>
            {
                s.SetCustomField(integrationId: "2", title: "cf title");
                s.SetCustomField(integrationId: "3", title: "cf title2");
            });
            var o = new Organization { Name = "Ankeborgs bibliotek" };
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
            _i.AddOrganization(o);
            _stream = new MemoryStream();
            new GoImportSerializer().Serialize(_stream, _i);
            _stream.Flush();
            _stream.Position = 0;
            _xsdFile = Path.Combine("..", "..", "..", "..", "spec", "sample_data", "schema0.xsd");
        }

        [TearDown]
        public void TearDown()
        {
            if (_stream != null)
            {
                _stream.Dispose();
                _stream = null;
            }
        }

        [Test]
        public void Is_valid()
        {
            var validations = GetValidations(_stream);
            var errors = validations.Where(validation=>validation.Item1==XmlSeverityType.Error);
            Assert.That(errors.ToArray(), Is.EquivalentTo(new String[0]));
        }

        private IEnumerable<Tuple<XmlSeverityType, string>> GetValidations(Stream memoryStream)
        {
            var validations = new List<Tuple<XmlSeverityType,String>>();
            var settings = new XmlReaderSettings
            {
                ValidationType = ValidationType.Schema
            };

            settings.Schemas.Add(null, _xsdFile);
            settings.ValidationEventHandler +=
                (sender, e) => validations.Add(new Tuple<XmlSeverityType, string>(e.Severity, e.Message));
            using (var validatingReader = XmlReader.Create(memoryStream, settings))
            {
                while (validatingReader.Read())
                {
                    /* make sure that the xml reader touches the entire document */
                }
            }
            return validations;
        }
    }
}
