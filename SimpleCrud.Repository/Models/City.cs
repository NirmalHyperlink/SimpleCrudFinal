using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace SimpleCrud.Repository.Models;

public partial class City
{
    [Key]
    public int Id { get; set; }

    [StringLength(100)]
    public string Name { get; set; } = null!;

    public int StateId { get; set; }

    [ForeignKey("StateId")]
    [InverseProperty("Cities")]
    public virtual State State { get; set; } = null!;

    [InverseProperty("City")]
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
