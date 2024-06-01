using System;
using Godot;

[GlobalClass]
public partial class LanguageFileConfigurationAttribute : GodotObject
{
    public string Name { get; set; }
    public string DisplayName { get; set; }
    public bool IsInt { get; set; } = false;
    public bool IsString { get; set; } = false;
    public bool IsBool { get; set; } = false;
    public bool IsFloat { get; set; } = false;
    public string[] EnumValues { get; set; } = Array.Empty<string>();
}