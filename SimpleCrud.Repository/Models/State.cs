using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace SimpleCrud.Repository.Models;

public partial class State
{
    [Key]
    public int Id { get; set; }

    [StringLength(100)]
    public string Name { get; set; } = null!;

    public int CountryId { get; set; }

    [InverseProperty("State")]
    public virtual ICollection<City> Cities { get; set; } = new List<City>();

    [ForeignKey("CountryId")]
    [InverseProperty("States")]
    public virtual Country Country { get; set; } = null!;

    [InverseProperty("State")]
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
