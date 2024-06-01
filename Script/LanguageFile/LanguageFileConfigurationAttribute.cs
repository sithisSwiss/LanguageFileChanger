using System;
using System.Collections.Generic;
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
    public List<string> EnumValues { get; set; } = new List<string>();
}