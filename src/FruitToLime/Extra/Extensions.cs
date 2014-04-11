using System;
using System.Collections.Generic;

namespace FruitToLime.Extra
{
    public static class Extensions
    {
        public static void WithOrganization(this Settings settings, Action<ClassSettings> organizationSettingsScope)
        {
            if (settings.Organization == null)
            {
                settings.Organization = new ClassSettings();
            }
            organizationSettingsScope(settings.Organization);
        }
        public static void WithPerson(this Settings settings, Action<ClassSettings> personSettingsScope)
        {
            if (settings.Person == null)
            {
                settings.Person = new ClassSettings();
            }
            personSettingsScope(settings.Person);
        }
        public static void WithDeal(this Settings settings, Action<ClassSettings> dealSettingsScope)
        {
            if (settings.Deal == null)
            {
                settings.Deal = new ClassSettings();
            }
            dealSettingsScope(settings.Deal);
        }

        public static CustomField SetCustomField(this ClassSettings settings, CustomField customField)
        {
            settings.CustomFields = settings.CustomFields == null
                ? new[] { customField }
                : new List<CustomField>(settings.CustomFields) { customField }.ToArray();
            return customField;
        }

        public static CustomField SetCustomField(this ClassSettings settings, string id = null, string integrationId = null, string title = null, string type = null)
        {
            return settings.SetCustomField(new CustomField
            {
                Id = id,
                IntegrationId = integrationId,
                Title = title,
                Type = type
            });
        }

        public static void WithSource(this IWithSource withSource, Action<ReferenceToSource> scopeWithReference)
        {
            if (withSource.Source == null)
            {
                withSource.Source = new ReferenceToSource();
            }
            scopeWithReference(withSource.Source);
        }

        public static void WithPostalAddress(this Organization organization, Action<Address> scopeWithAddress)
        {
            if (organization.PostalAddress == null)
            {
                organization.PostalAddress = new Address();
            }
            scopeWithAddress(organization.PostalAddress);
        }

        public static void WithVisitAddress(this Organization organization, Action<Address> scopeWithAddress)
        {
            if (organization.VisitAddress == null)
            {
                organization.VisitAddress = new Address();
            }
            scopeWithAddress(organization.VisitAddress);
        }
        public static void AddTag(this IWithTags withTags, string tag)
        {
            withTags.Tags = withTags.Tags == null
                ? new[] { tag }
                : new List<string>(withTags.Tags) { tag }.ToArray();
        }

        public static CustomValue SetCustomField(this IWithCustomValues withCustomValues, string id = null, string integrationId = null, string value = null)
        {
            var customValue = new CustomValue { Value = value, Field = new CustomFieldReference { Id = id, IntegrationId = integrationId } };
            withCustomValues.CustomValues = withCustomValues.CustomValues == null
                ? new[] { customValue }
                : new List<CustomValue>(withCustomValues.CustomValues) { customValue }.ToArray();
            return customValue;
        }

        public static CoworkerReference AddResponsibleCoworker(this Organization organization, string id = null, string integrationId = null, string heading = null)
        {
            if (organization.ResponsibleCoworker == null)
            {
                organization.ResponsibleCoworker = new CoworkerReference();
            }
            organization.ResponsibleCoworker.IntegrationId = integrationId;
            organization.ResponsibleCoworker.Id = id;
            organization.ResponsibleCoworker.Heading = heading;
            return organization.ResponsibleCoworker;
        }

        public static Person AddEmployee(this Organization organization, Person employee)
        {
            organization.Employees= organization.Employees== null
                ? new[] { employee }
                : new List<Person>(organization.Employees) { employee }.ToArray();
            return employee;
        }

        public static Person AddEmployee(this Organization organization, string id = null, string integrationId = null, string firstName = null, string lastName = null)
        {
            return AddEmployee(organization, new Person()
            {
                Id = id,
                IntegrationId = integrationId,
                FirstName = firstName,
                LastName = lastName
            });
        }

        public static ReferenceToSource ParSe(this ReferenceToSource reference, string id)
        {
            reference.Name = "pase";
            reference.Format = ReferenceFormat.External;
            reference.Id = id;
            return reference;
        }

        public static Organization AddOrganization(this GoImport import, Organization organization)
        {
            import.Organizations = import.Organizations == null
             ? new[] { organization }
             : new List<Organization>(import.Organizations) { organization }.ToArray();
            return organization;
        }

    }
}
