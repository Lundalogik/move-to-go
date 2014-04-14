using System.IO;
using System.Linq.Expressions;
using System.Xml;
using System.Xml.Serialization;

namespace FruitToLime
{

    public class GoImportSerializer
    {
        private readonly XmlSerializer _xmlSerializer;

        public GoImportSerializer()
        {
            _xmlSerializer = new XmlSerializer(typeof(GoImport));
        }

        public GoImport Deserialize(Stream s)
        {
            return (GoImport)_xmlSerializer.Deserialize(s);
        }

        public void Serialize(Stream s, GoImport ioRoot)
        {
            _xmlSerializer.Serialize(s, ioRoot);
        }

        public string Serialize(GoImport ioRoot)
        {
            using (var s = new MemoryStream())
            using (var reader = new StreamReader(s))
            {
                _xmlSerializer.Serialize(s, ioRoot);
                s.Flush();
                s.Position = 0;
                return reader.ReadToEnd();
            }
        }
    }
}
