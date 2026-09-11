using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Win32;
using System.Runtime.InteropServices;

namespace WU_Pending
{
    internal class Program
    {
        private const string RegistryPath = @"SOFTWARE\Pending updates";

        static void Main(string[] args)
        {
            try
            {
                Console.WriteLine("Windows Update Pending Utility");
                Console.WriteLine("================================");
                Console.WriteLine("Scanning for Windows updates...\n");

                // Clear registry before scan
                ClearRegistryKey();

                // Scan for updates
                var updates = ScanForUpdates();

                // Store results in registry
                StoreUpdatesToRegistry(updates);

                Console.WriteLine($"\nScan completed successfully.");
                Console.WriteLine($"Found {updates.Count} pending update(s).");
                Console.WriteLine($"Results stored in: HKEY_LOCAL_MACHINE\\{RegistryPath}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Stack Trace: {ex.StackTrace}");
                Environment.Exit(1);
            }
        }

        /// <summary>
        /// Scans for available Windows updates
        /// </summary>
        private static List<UpdateInfo> ScanForUpdates()
        {
            var updates = new List<UpdateInfo>();

            try
            {
                // Use dynamic type to access WUApiLib COM objects
                dynamic updateSession = Activator.CreateInstance(Type.GetTypeFromProgID("Microsoft.Update.Session"));
                dynamic updateSearcher = updateSession.CreateUpdateSearcher();

                Console.WriteLine("Connecting to Windows Update service...");
                dynamic searchResult = updateSearcher.Search("IsInstalled=0");

                Console.WriteLine($"Search completed. Found {searchResult.Updates.Count} update(s).\n");

                foreach (dynamic update in searchResult.Updates)
                {
                    var updateInfo = new UpdateInfo
                    {
                        Title = update.Title,
                        Description = update.Description,
                        KBArticleID = GetKBArticleID(update),
                        IsMandatory = update.IsMandatory,
                        IsHidden = update.IsHidden,
                        DeadlineDate = update.Deadline ?? "",
                        Categories = GetCategories(update)
                    };

                    updates.Add(updateInfo);

                    Console.WriteLine($"Update: {update.Title}");
                    Console.WriteLine($"  KB Article: {updateInfo.KBArticleID}");
                    Console.WriteLine($"  Mandatory: {update.IsMandatory}");
                    Console.WriteLine($"  Categories: {updateInfo.Categories}\n");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error during update search: {ex.Message}");
                throw;
            }

            return updates;
        }

        /// <summary>
        /// Stores update information to the Windows registry
        /// </summary>
        private static void StoreUpdatesToRegistry(List<UpdateInfo> updates)
        {
            RegistryKey baseKey = null;
            RegistryKey key = null;

            try
            {
                baseKey = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry64);
                key = baseKey.CreateSubKey(RegistryPath, RegistryKeyPermissionCheck.ReadWriteSubTree);

                if (key == null)
                {
                    throw new Exception($"Unable to create or access registry key: {RegistryPath}");
                }

                // Store metadata
                key.SetValue("ScanDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
                key.SetValue("UpdateCount", updates.Count);

                // Store each update
                for (int i = 0; i < updates.Count; i++)
                {
                    var update = updates[i];
                    string indexPrefix = $"Update{i + 1}_";

                    key.SetValue(indexPrefix + "Title", update.Title ?? "");
                    key.SetValue(indexPrefix + "Description", TruncateValue(update.Description ?? ""));
                    key.SetValue(indexPrefix + "KB", update.KBArticleID ?? "N/A");
                    key.SetValue(indexPrefix + "Mandatory", update.IsMandatory.ToString());
                    key.SetValue(indexPrefix + "Hidden", update.IsHidden.ToString());
                    key.SetValue(indexPrefix + "Deadline", update.DeadlineDate ?? "N/A");
                    key.SetValue(indexPrefix + "Categories", update.Categories ?? "");
                }

                // Flush changes to disk
                key.Flush();

                Console.WriteLine($"Data stored in registry at: HKEY_LOCAL_MACHINE\\{RegistryPath}");
            }
            catch (UnauthorizedAccessException ex)
            {
                Console.WriteLine($"Access denied writing to registry: {ex.Message}");
                Console.WriteLine("Please run this utility as Administrator for full functionality.");
                throw;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error storing data to registry: {ex.Message}");
                throw;
            }
            finally
            {
                key?.Dispose();
                baseKey?.Dispose();
            }
        }

        /// <summary>
        /// Clears the registry key before scanning
        /// </summary>
        private static void ClearRegistryKey()
        {
            try
            {
                using (RegistryKey baseKey = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry64))
                {
                    baseKey.DeleteSubKey(RegistryPath, false);
                    Console.WriteLine($"Cleared existing registry key: {RegistryPath}\n");
                }
            }
            catch (System.IO.IOException)
            {
                // Key doesn't exist yet, which is fine
                Console.WriteLine($"Registry key does not exist yet. Will be created.\n");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error clearing registry key: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Extracts KB article ID from update using dynamic
        /// </summary>
        private static string GetKBArticleID(dynamic update)
        {
            try
            {
                foreach (string id in update.KBArticleIDs)
                {
                    return id;
                }
            }
            catch { }

            return "N/A";
        }

        /// <summary>
        /// Gets categories from update using dynamic
        /// </summary>
        private static string GetCategories(dynamic update)
        {
            try
            {
                var categories = new List<string>();
                foreach (dynamic category in update.Categories)
                {
                    categories.Add(category.Name);
                }
                return string.Join("; ", categories);
            }
            catch
            {
                return "";
            }
        }

        /// <summary>
        /// Truncates registry values to fit Registry data limits
        /// </summary>
        private static string TruncateValue(string value)
        {
            const int maxLength = 16000; // Registry value size limit
            return value.Length > maxLength ? value.Substring(0, maxLength) : value;
        }
    }

    /// <summary>
    /// Information about a Windows Update
    /// </summary>
    internal class UpdateInfo
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public string KBArticleID { get; set; }
        public bool IsMandatory { get; set; }
        public bool IsHidden { get; set; }
        public string DeadlineDate { get; set; }
        public string Categories { get; set; }
    }
}
